#!/bin/sh
# Exercise deployment filters using disposable local files, without a database or server.

set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "${SCRIPT_DIR}/../../.." && pwd)"

if ! command -v rsync >/dev/null 2>&1; then
    echo "rsync is required for the deployment filter check." >&2
    exit 1
fi

# Check both workflow entry points, including rule order. Ordinary excludes would
# protect old test files from deletion; --delete-excluded would also risk server data.
for environment in staging production; do
    workflow="${REPO_ROOT}/.github/workflows/deploy-${environment}.yml"
    switches="$(sed -n 's/^[[:space:]]*switches: //p' "${workflow}" | tr -d '\r')"
    case "${switches}" in
        *"--filter='merge .github/deploy.rsync-filter'"*"--exclude-from='.gitignore'"*) ;;
        *) echo "Missing or incorrectly ordered deployment filters: ${workflow}" >&2; exit 1 ;;
    esac
    case "${switches}" in
        *--delete-excluded*) echo "Unsafe global deletion option: ${workflow}" >&2; exit 1 ;;
    esac
done

temp_parent="$(CDPATH= cd -- "${TMPDIR:-/tmp}" && pwd -P)"
fixture_root="$(mktemp -d "${temp_parent}/saaster-deploy-filter.XXXXXX")"
fixture_root="$(CDPATH= cd -- "${fixture_root}" && pwd -P)"

cleanup() {
    # Verify the resolved target belongs to the temporary directory created above.
    case "${fixture_root}" in
        "${temp_parent}"/saaster-deploy-filter.*) rm -rf -- "${fixture_root}" ;;
        *) echo "Refusing to clean an unexpected fixture path: ${fixture_root}" >&2 ;;
    esac
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM

write_file() {
    mkdir -p "$(dirname -- "$1")"
    printf '%s\n' "$2" > "$1"
}

assert_absent() {
    if [ -e "$1" ] || [ -L "$1" ]; then
        echo "Unexpected deployed development asset: $1" >&2
        exit 1
    fi
}

assert_content() {
    if [ ! -f "$1" ] || [ "$(cat "$1")" != "$2" ]; then
        echo "Missing or changed deployment fixture: $1" >&2
        exit 1
    fi
}

source_dir="${fixture_root}/source"
write_file "${source_dir}/www/index.cfm" "application"
write_file "${source_dir}/www/setup/index.cfm" "installer"
write_file "${source_dir}/config/db/core/V1__fixture.sql" "core migration"
write_file "${source_dir}/config/db/myapp/V1__fixture.sql" "project migration"
write_file "${source_dir}/www/backend/myapp/tests/keep.cfm" "project-owned tests"
write_file "${source_dir}/config/db/myapp/dev/keep.sql" "project-owned directory"
write_file "${source_dir}/www/tests/runner.cfm" "test runner"
write_file "${source_dir}/www/tests/support/fixture.cfc" "test fixture"
write_file "${source_dir}/config/db/dev/create-demo.sql" "demo seed"
write_file "${source_dir}/www/setup/mockdata/index.cfm" "mock generator"

# These source values must neither be uploaded nor replace the server's values.
for protected_path in .env www/config.cfm www/userdata/upload.txt config/nginx/conf.d/base.conf config/nginx/conf.d/custom.conf logs/keep.log; do
    write_file "${source_dir}/${protected_path}" "checkout value"
done

cd "${REPO_ROOT}"

for scenario in staging-fresh staging-existing production-fresh production-existing; do
    environment="${scenario%-*}"
    destination_state="${scenario#*-}"
    switches="$(sed -n 's/^[[:space:]]*switches: //p' ".github/workflows/deploy-${environment}.yml" | tr -d '\r')"
    destination="${fixture_root}/${scenario}"
    mkdir -p "${destination}"

    if [ "${destination_state}" = existing ]; then
        for development_path in www/tests config/db/dev www/setup/mockdata; do
            write_file "${destination}/${development_path}/old.txt" "previously deployed"
            # Even names normally protected by .gitignore must be removed inside
            # these development-only trees, without weakening protection elsewhere.
            write_file "${destination}/${development_path}/config.cfm" "old development config"
            write_file "${destination}/${development_path}/.env" "old development environment"
        done
        for protected_path in .env www/config.cfm www/userdata/upload.txt config/nginx/conf.d/base.conf config/nginx/conf.d/custom.conf logs/keep.log; do
            write_file "${destination}/${protected_path}" "server value"
        done
    fi

    # xargs decodes the workflow's static quoted arguments without evaluating
    # them as shell code. Test the actual options from each deployment workflow.
    printf '%s\n' "${switches}" | \
        SAASTER_FILTER_SOURCE="${source_dir}" SAASTER_FILTER_DESTINATION="${destination}" \
        xargs sh -c 'exec rsync "$@" "${SAASTER_FILTER_SOURCE}/" "${SAASTER_FILTER_DESTINATION}/"' sh >/dev/null

    for development_path in www/tests config/db/dev www/setup/mockdata; do
        assert_absent "${destination}/${development_path}"
    done
    assert_content "${destination}/www/index.cfm" "application"
    assert_content "${destination}/www/setup/index.cfm" "installer"
    assert_content "${destination}/config/db/core/V1__fixture.sql" "core migration"
    assert_content "${destination}/config/db/myapp/V1__fixture.sql" "project migration"
    assert_content "${destination}/www/backend/myapp/tests/keep.cfm" "project-owned tests"
    assert_content "${destination}/config/db/myapp/dev/keep.sql" "project-owned directory"

    for protected_path in .env www/config.cfm www/userdata/upload.txt config/nginx/conf.d/base.conf config/nginx/conf.d/custom.conf logs/keep.log; do
        if [ "${destination_state}" = existing ]; then
            assert_content "${destination}/${protected_path}" "server value"
        else
            assert_absent "${destination}/${protected_path}"
        fi
    done
    echo "Deployment filters passed: ${scenario} destination."
done

# A deployment must leave the checkout's development assets available for forks and tests.
assert_content "${source_dir}/www/tests/runner.cfm" "test runner"
assert_content "${source_dir}/www/tests/support/fixture.cfc" "test fixture"
assert_content "${source_dir}/config/db/dev/create-demo.sql" "demo seed"
assert_content "${source_dir}/www/setup/mockdata/index.cfm" "mock generator"
