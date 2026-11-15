#!/usr/bin/env bash
# Build and run the isolated staging checks without deployment credentials.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
cd "${REPO_ROOT}"

# This script generates configuration and recreates its own test database.
# Refuse existing installations instead of replacing any local settings.
for path in .env www/config.cfm www/tests/config/testing.env www/tests/config/testing.json config/nginx/conf.d/base.conf; do
    if [[ -e "${path}" || -L "${path}" ]]; then
        echo "Aborted: ${path} exists. Run staging checks from a fresh checkout." >&2
        exit 1
    fi
done

project="saaster-ci-${GITHUB_RUN_ID:-$$}-${GITHUB_RUN_ATTEMPT:-1}"
port="${SAASTER_CI_HTTP_PORT:-18080}"
if [[ ! "${project}" =~ ^saaster-ci-[0-9]+-[0-9]+$ || ! "${port}" =~ ^[0-9]{1,5}$ ]] || (( 10#${port} < 1 || 10#${port} > 65535 )); then
    echo "Aborted: invalid isolated project name or HTTP port." >&2
    exit 1
fi

if [[ -n "$(docker ps -aq --filter "label=com.docker.compose.project=${project}")" || -n "$(docker volume ls -q --filter "label=com.docker.compose.project=${project}")" ]]; then
    echo "Aborted: the isolated project already exists: ${project}" >&2
    exit 1
fi

random_password() {
    od -An -N24 -tx1 /dev/urandom | tr -d ' \n'
}

umask 077
mysql_password="$(random_password)"
cat > .env <<EOF
COMPOSE_PROJECT_NAME=${project}
LUCEE_CONTAINER_NAME=${project}-lucee
LUCEE_PORT=${port}
LUCEE_ADMIN_PASSWORD=$(random_password)
MYSQL_CONTAINER_NAME=${project}-mysql
MYSQL_DATABASE=saaster_ci_unused
MYSQL_ROOT_PASSWORD=$(random_password)
MYSQL_USER=saaster_test_user
MYSQL_PASSWORD=${mysql_password}
INBUCKET_CONTAINER_NAME=${project}-inbucket
TEST_COMPOSE_FILE=www/tests/compose.yml
TEST_MYSQL_DATABASE=saaster_ci_test
TEST_MYSQL_HOST=${project}-mysql
TEST_MYSQL_PORT=3306
TEST_MYSQL_USER=saaster_test_user
TEST_MYSQL_PASSWORD=${mysql_password}
TEST_DATASOURCE_NAME=saaster_ci_test
TEST_APP_BASE_URL=http://127.0.0.1:${port}
EOF
load_test_environment
guard_test_database_name

mkdir -p config/nginx/conf.d
awk '/proxy_pass http:\/\/tomcat_backend;/ { print "        proxy_read_timeout 300s;" } { print }' \
    config/example.base.conf > config/nginx/conf.d/base.conf
cp config/example.config_dev.cfm www/config.cfm
cat >> www/config.cfm <<EOF

<cfscript>
variables.datasource = "saaster_ci_test";
variables.applicationname = "${project}";
variables.mainURL = "${TEST_APP_BASE_URL}";
variables.schedulePassword = "$(random_password)";
// Any payment HTTP request must stay inside the test application.
variables.payrexxAPIurl = "http://127.0.0.1/tests/support/payrexx_mock.cfm?route=/";
</cfscript>
EOF

compose=(docker compose -p "${project}" -f "${TEST_COMPOSE_FILE}")
started=false
cleanup() {
    local result=$?
    trap - EXIT
    if [[ "${started}" == true ]]; then
        if (( result != 0 )); then
            "${compose[@]}" logs --no-color --tail 60 lucee mysql inbucket >&2 || true
        fi
        if ! "${compose[@]}" down --volumes; then
            echo "Failed to remove the isolated test stack." >&2
            result=1
        fi
    fi
    exit "${result}"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

started=true
"${compose[@]}" up -d --wait --wait-timeout 180 mysql inbucket lucee
bash www/tests/bin/install_test_dependencies.sh
bash www/tests/bin/prepare_test_db.sh
# Validate both histories and prove that a second migration is a no-op.
bash www/tests/bin/migrate_test_db.sh

ready=false
for attempt in {1..10}; do
    if curl --fail --silent --show-error --connect-timeout 5 --max-time 60 \
        "${TEST_APP_BASE_URL}/tests/healthcheck.cfm"; then
        ready=true
        break
    fi
    echo "Waiting for the test application (${attempt}/10)." >&2
    sleep 3
done
if [[ "${ready}" != true ]]; then
    echo "The isolated test application did not become ready." >&2
    exit 1
fi
echo
bash www/tests/bin/run_tests.sh 'reporter=mintext'
