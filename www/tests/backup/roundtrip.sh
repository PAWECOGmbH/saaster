#!/usr/bin/env bash
# Executed only by check_borg_backup.sh inside its disposable Linux controller.
set -Eeuo pipefail
trap 'printf "Test failed at line %s\n" "$LINENO" >&2' ERR
project="${SAASTER_BORG_TEST_PROJECT:?Missing isolated test project}"
[[ "$project" == saaster-borg-test-* && "$PWD" == /var/lib/docker/volumes/"$project-workspace"/_data/project ]] || {
    echo 'Refusing an unexpected test workspace.' >&2; exit 1;
}
root="$PWD"
export ENV_FILE="$root/.env"
random_password() { od -An -N24 -tx1 /dev/urandom | tr -d ' \n'; }
mkdir -p /borg-test /test-state /backup config/nginx/conf.d config/mysql
random_password > /borg-test/passphrase
cat > .env <<EOF
COMPOSE_PROJECT_NAME=$project
BACKUP_ENV=test
BORG_COMPOSE_FILE=www/tests/backup/compose.yml
BORG_TEST_ROOT=$root
BORG_REPO=/borg-test/repository
BORG_PASSPHRASE_FILE=/borg-test/passphrase
BORG_WORK_DIR=/backup
BORG_KEEP_DAILY=1
BORG_KEEP_WEEKLY=0
BORG_KEEP_MONTHLY=0
LUCEE_IMAGE=lucee/lucee
LUCEE_IMAGE_VERSION=7.1.1.17-nginx
LUCEE_ADMIN_PASSWORD=$(random_password)
MYSQL_DATABASE=saaster_borg_test_db
MYSQL_ROOT_PASSWORD=$(random_password)
MYSQL_USER=saaster_borg_test_user
MYSQL_PASSWORD=$(random_password)
EOF
set -a; source .env; set +a
BORG_PASSPHRASE="$(<"$BORG_PASSPHRASE_FILE")"
export BORG_PASSPHRASE
compose() { docker compose --env-file "$ENV_FILE" -p "$project" -f www/tests/backup/compose.yml "$@"; }
mysql_id() { compose ps -q mysql; }
lucee_id() { compose ps -q lucee; }
sql() { docker exec -i "$(mysql_id)" sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysql --user=root --batch --skip-column-names "$MYSQL_DATABASE"'; }
probe() { docker exec "$(lucee_id)" wget -q -O - -T 60 "http://127.0.0.1/__borg_recovery_probe.cfm?action=$1"; }
expect_failure() {
    local message="$1"
    shift
    if "$@" > /test-state/negative.log 2>&1; then cat /test-state/negative.log; echo "Expected failure: $*" >&2; exit 1; fi
    if ! grep -Fq -- "$message" /test-state/negative.log; then
        cat /test-state/negative.log >&2
        echo "Missing expected error: $message" >&2
        exit 1
    fi
}
assert_same() { [[ "$1" == "$2" ]] || { echo "Mismatch: $3" >&2; exit 1; }; }
cleanup() {
    local result=$?
    trap - EXIT
    if (( result != 0 )); then
        for body in /test-state/before-login.json /test-state/after-login.json; do
            if [[ -f "$body" ]]; then head -c 4000 "$body" >&2; fi
        done
        compose logs --no-color --tail 12 lucee mysql >&2 || true
    fi
    compose down --volumes >/dev/null || true
    exit "$result"
}
trap cleanup EXIT
cp config/example.base.conf config/nginx/conf.d/base.conf
printf '\n# Borg recovery fixture configuration\n' >> config/nginx/conf.d/base.conf
printf '[mysqld]\nmax_connections=83\n' > config/mysql/tuning.cnf
cp config/example.config_dev.cfm www/config.cfm
cat >> www/config.cfm <<EOF
<cfscript>
variables.datasource = "saaster_borg_test";
variables.applicationname = "$project";
variables.mainURL = "http://localhost";
variables.payrexxAPIurl = "http://127.0.0.1/tests/support/payrexx_mock.cfm?route=/";
this.datasources = {saaster_borg_test: {
    class: "com.mysql.cj.jdbc.Driver", bundleName: "com.mysql.cj", bundleVersion: "9.6.0",
    connectionString: "jdbc:mysql://mysql:3306/$MYSQL_DATABASE?allowPublicKeyRetrieval=true&useSSL=false&allowMultiQueries=true&characterEncoding=UTF-8",
    username: "$MYSQL_USER", password: "$MYSQL_PASSWORD"
}};
this.mailServers = [{host:"inbucket",port:2500}];
</cfscript>
EOF
cp www/tests/backup/recovery_probe.cfm www/__borg_recovery_probe.cfm
printf 'custom application source\n' > www/backend/myapp/borg-recovery-marker.txt
python3 - <<'PY'
import sqlite3
c=sqlite3.connect("filebrowser.db")
c.execute("create table fixture(value text)")
c.execute("insert into fixture values ('original filebrowser configuration')")
c.commit(); c.close()
PY
compose up -d --wait --wait-timeout 180 mysql inbucket lucee
for folder in core myapp; do
    compose run --rm --no-deps flyway "-url=jdbc:mysql://mysql:3306/$MYSQL_DATABASE?allowPublicKeyRetrieval=true&useSSL=false" \
        "-locations=filesystem:/flyway/sql/$folder" "-table=flyway_$folder" -baselineOnMigrate=true migrate
done
ready=false
for attempt in {1..12}; do
    if probe seed > /test-state/before-login.json; then ready=true; break; fi
    echo "Waiting for Lucee ($attempt/12)"; sleep 3
done
[[ "$ready" == true ]]
python3 -c 'import json; x=json.load(open("/test-state/before-login.json")); assert x["OK"] and x["DATABASE"]=="saaster_borg_test_db"'
sql <<'SQL'
CREATE TABLE borg_roundtrip (id INT PRIMARY KEY, payload VARBINARY(64));
INSERT INTO borg_roundtrip VALUES (1,UNHEX('0001FF41424300'));
CREATE PROCEDURE borg_probe_procedure() SELECT 42;
CREATE TRIGGER borg_probe_trigger BEFORE INSERT ON borg_roundtrip FOR EACH ROW SET NEW.id=NEW.id;
CREATE EVENT borg_probe_event ON SCHEDULE AT '2099-01-01 00:00:00' DO SELECT 1;
SQL
docker exec "$(lucee_id)" sh -c 'mkdir -p /var/www/userdata/nested; printf "original invoice bytes\n" > /var/www/userdata/nested/invoice.pdf; printf "hidden bytes\n" > /var/www/userdata/.hidden; printf "runtime administrator marker\n" > /opt/lucee/server/lucee-server/context/borg-recovery-marker.txt'
history="$(printf 'SELECT CONCAT(version,":",COALESCE(checksum,""),":",success) FROM flyway_core ORDER BY installed_rank; SELECT CONCAT(version,":",COALESCE(checksum,""),":",success) FROM flyway_myapp ORDER BY installed_rank;\n' | sql)"
config_hash="$(sha256sum www/config.cfm | cut -d' ' -f1)"
nginx_hash="$(sha256sum config/nginx/conf.d/base.conf | cut -d' ' -f1)"
filebrowser_hash="$(sha256sum filebrowser.db | cut -d' ' -f1)"
bash config/backup/backup_borg.sh --init
bash config/backup/backup_borg.sh --export-key /borg-test/exported-key
bash config/backup/backup_borg.sh --backup
prefix="$project-saaster-v1"
first="$(borg list --short "$BORG_REPO" | grep "^$prefix-complete-" | sort | tail -n1)"
[[ -n "$first" ]]
echo 'PASS: encrypted backup created; application restarted.'
[[ "$(docker inspect --format '{{.State.Running}}' "$(lucee_id)")" == true ]]
expect_failure 'use --force' bash config/backup/restore_borg.sh --all
cp .env /test-state/wrong.env
printf '\nMYSQL_PASSWORD=wrong-test-password\n' >> /test-state/wrong.env
expect_failure 'credentials from --config' env ENV_FILE=/test-state/wrong.env bash config/backup/restore_borg.sh --all --force
cp .env /test-state/disabled.env
printf '\nBACKUP_ENV=development\n' >> /test-state/disabled.env
expect_failure 'Set BACKUP_ENV' env ENV_FILE=/test-state/disabled.env bash config/backup/backup_borg.sh --backup
exec 8>>"/run/saaster-backup/$project.lock"
flock -n 8
expect_failure 'already running' bash config/backup/backup_borg.sh --backup
flock -u 8
echo 'PASS: force, environment, credential and concurrent-run guards.'
mkdir -p /test-state/fail-bin
cat > /test-state/fail-bin/docker <<'SH'
#!/usr/bin/env bash
if [[ "$1" == exec && "$*" == *mysqldump* ]]; then
    echo 'Injected test dump failure' >&2
    exit 42
fi
exec "$REAL_DOCKER" "$@"
SH
chmod 700 /test-state/fail-bin/docker
expect_failure 'Injected test dump failure' env REAL_DOCKER="$(command -v docker)" PATH="/test-state/fail-bin:$PATH" bash config/backup/backup_borg.sh --backup
[[ "$(docker inspect --format '{{.State.Running}}' "$(lucee_id)")" == true ]]
[[ -z "$(docker image ls -q --filter "reference=saaster-borg-snapshot/$project:*")" ]]
[[ -z "$(find /backup -mindepth 1 -maxdepth 1 -type d -print -quit)" ]]
echo 'PASS: a failed database capture restarts the application and cleans temporary data.'
mkdir -p /test-state/empty
borg create "$BORG_REPO::unrelated-project-keep" /test-state/empty
bash config/backup/backup_borg.sh --backup
archives="$(borg list --short "$BORG_REPO")"
if grep -Fxq "$first" <<< "$archives"; then echo 'Old complete set was not pruned.' >&2; exit 1; fi
for component in db userdata config lucee; do
    if grep -Fxq "${first/-complete-/-$component-}" <<< "$archives"; then echo 'Incomplete retention cleanup.' >&2; exit 1; fi
done
grep -Fxq unrelated-project-keep <<< "$archives"
echo 'PASS: retention removes complete sets and preserves unrelated archives.'
latest="$(grep "^$prefix-complete-" <<< "$archives" | sort | tail -n1)"
timestamp="${latest#"$prefix-complete-"}"
borg create "$BORG_REPO::$prefix-db-20991231T235959Z" /test-state/empty
borg create "$BORG_REPO::$prefix-complete-20991231T235959Z" /test-state/empty
expect_failure 'No complete backup set' bash config/backup/restore_borg.sh --all --timestamp 20991231T235959Z --force
expect_failure 'Retention skipped: incomplete completion record' bash -c \
    'source config/backup/borg_common.sh; ARCHIVE_PREFIX="$1"; assert_complete_records "$2"' _ "$prefix" "$(borg list --short "$BORG_REPO")"
echo 'PASS: an incomplete newer set is rejected.'

# Destroy only this fixture project: the backup repository and controller live
# in separate volumes and are deliberately not part of the Compose stack.
[[ "$project" == saaster-borg-test-* && "$MYSQL_DATABASE" == *test* ]]
compose down --volumes
bash config/backup/restore_borg.sh --config --timestamp "$timestamp"
bash config/backup/restore_borg.sh --lucee-image --timestamp "$timestamp" --force
[[ -n "$(docker image inspect --format '{{.Id}}' "saaster-borg-snapshot/$project:$timestamp")" ]]
echo 'PASS: configuration and runtime image can be recovered without existing containers.'
printf 'damaged application configuration\n' > www/config.cfm
printf 'damaged source\n' > www/backend/myapp/borg-recovery-marker.txt
printf '# damaged configuration\n' > config/nginx/conf.d/base.conf
printf 'damaged filebrowser\n' > filebrowser.db
printf '[mysqld]\nmax_connections=17\n' > config/mysql/tuning.cnf
# Let the placeholder container start with valid NGINX; the archived original
# is checked separately and reapplied by --all.
cp config/example.base.conf config/nginx/conf.d/base.conf
compose up -d --wait --wait-timeout 180 mysql inbucket lucee
docker exec "$(lucee_id)" sh -c 'printf "stale replacement data\n" > /var/www/userdata/stale.txt'
bash config/backup/restore_borg.sh --all --force
set -a; source .env; set +a
assert_same "$config_hash" "$(sha256sum www/config.cfm | cut -d' ' -f1)" 'application configuration'
assert_same "$nginx_hash" "$(sha256sum config/nginx/conf.d/base.conf | cut -d' ' -f1)" 'NGINX configuration'
assert_same "$filebrowser_hash" "$(sha256sum filebrowser.db | cut -d' ' -f1)" 'Filebrowser database'
assert_same 'custom application source' "$(cat www/backend/myapp/borg-recovery-marker.txt)" 'custom application code'
assert_same 'original invoice bytes' "$(docker exec "$(lucee_id)" cat /var/www/userdata/nested/invoice.pdf)" 'userdata'
assert_same 'hidden bytes' "$(docker exec "$(lucee_id)" cat /var/www/userdata/.hidden)" 'hidden userdata'
docker exec "$(lucee_id)" test ! -e /var/www/userdata/stale.txt
[[ -z "$(docker exec "$(lucee_id)" find /var/www/userdata -maxdepth 1 -name '.saaster-borg-rollback.*' -print -quit)" ]]
assert_same '83' "$(printf 'SELECT @@max_connections;\n' | sql)" 'recovered MySQL server settings'
assert_same 'runtime administrator marker' "$(docker exec "$(lucee_id)" cat /opt/lucee/server/lucee-server/context/borg-recovery-marker.txt)" 'post-image Lucee runtime configuration'
restored_history="$(printf 'SELECT CONCAT(version,":",COALESCE(checksum,""),":",success) FROM flyway_core ORDER BY installed_rank; SELECT CONCAT(version,":",COALESCE(checksum,""),":",success) FROM flyway_myapp ORDER BY installed_rank;\n' | sql)"
assert_same "$history" "$restored_history" 'Flyway histories and checksums'
assert_same '0001FF41424300' "$(printf 'SELECT HEX(payload) FROM borg_roundtrip WHERE id=1;\n' | sql)" 'binary database content'
assert_same '1' "$(printf 'SELECT COUNT(*) FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA=DATABASE() AND ROUTINE_NAME="borg_probe_procedure";\n' | sql)" 'stored routine'
assert_same '1' "$(printf 'SELECT COUNT(*) FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA=DATABASE() AND TRIGGER_NAME="borg_probe_trigger";\n' | sql)" 'trigger'
assert_same '1' "$(printf 'SELECT COUNT(*) FROM information_schema.EVENTS WHERE EVENT_SCHEMA=DATABASE() AND EVENT_NAME="borg_probe_event";\n' | sql)" 'event'
ready=false
for attempt in {1..12}; do
    if probe status > /test-state/after-login.json; then ready=true; break; fi
    echo "Waiting for restored Lucee ($attempt/12)"; sleep 3
done
[[ "$ready" == true ]]
python3 - <<'PY'
import json
before=json.load(open('/test-state/before-login.json'))
after=json.load(open('/test-state/after-login.json'))
assert before==after and after['OK'], (before,after)
PY
assert_same "saaster-borg-snapshot/$project:$timestamp" "$LUCEE_IMAGE:$LUCEE_IMAGE_VERSION" 'recovered private runtime image'
bash config/backup/backup_borg.sh --check
echo 'PASS: empty-volume restore, app login, source/configuration, userdata, database and runtime image.'
echo 'PASS: full Borg cryptographic data verification.'
