#!/usr/bin/env bash
#
# Writes www/tests/config/testing.json from the project .env. The file is the
# only source of credentials for the test application in Lucee.

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

load_test_environment
guard_test_database_name

config_file="${TESTS_ROOT}/config/testing.json"

# No Python or Node here - neither is guaranteed on the host. Passwords can
# contain quotes and backslashes that must be escaped in JSON.
escape_json() {
    local raw="${1}"
    raw="${raw//\\/\\\\}"
    raw="${raw//\"/\\\"}"
    printf '%s' "${raw}"
}

{
    printf '{\n'
    printf '    "datasourceName": "%s",\n' "$(escape_json "${TEST_DATASOURCE_NAME}")"
    printf '    "database": "%s",\n' "$(escape_json "${TEST_MYSQL_DATABASE}")"
    printf '    "host": "%s",\n' "$(escape_json "${TEST_MYSQL_HOST}")"
    printf '    "port": %s,\n' "${TEST_MYSQL_PORT}"
    printf '    "user": "%s",\n' "$(escape_json "${TEST_MYSQL_USER}")"
    printf '    "password": "%s",\n' "$(escape_json "${TEST_MYSQL_PASSWORD}")"
    # Optional: Inbucket of compose-dev.yml - the specs that check sent mails read it there
    printf '    "mailCatcherUrl": "http://%s:9000"\n' "$(escape_json "${INBUCKET_CONTAINER_NAME:-saaster_inbucket}")"
    printf '}\n'
} > "${config_file}"

echo "Written: ${config_file}"
