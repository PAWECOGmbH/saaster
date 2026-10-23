#!/usr/bin/env bash
#
# Shared helpers of the test scripts: paths, loading .env, safety rules.

set -euo pipefail

TEST_BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_ROOT="$(cd "${TEST_BIN_DIR}/.." && pwd)"
WEB_ROOT="$(cd "${TESTS_ROOT}/.." && pwd)"
REPO_ROOT="$(cd "${WEB_ROOT}/.." && pwd)"

trim_value() {
    local raw_value="${1}"
    raw_value="${raw_value#"${raw_value%%[![:space:]]*}"}"
    raw_value="${raw_value%"${raw_value##*[![:space:]]}"}"
    printf '%s' "${raw_value}"
}

# The project .env has comments behind the values
# ("LUCEE_PORT=8080 # Must be unique"). They have to go, otherwise the
# comment ends up in the port. Windows line endings are stripped as well.
load_env_file() {
    local env_file="${1}"
    local line key value

    [[ -f "${env_file}" ]] || return 0

    while IFS= read -r line || [[ -n "${line}" ]]; do
        line="${line//$'\r'/}"
        line="$(trim_value "${line}")"
        [[ -n "${line}" ]] || continue
        [[ "${line}" == \#* ]] && continue
        [[ "${line}" == *=* ]] || continue

        key="$(trim_value "${line%%=*}")"
        value="${line#*=}"
        value="${value%% \#*}"
        value="$(trim_value "${value}")"

        if [[ "${value}" == \"*\" ]]; then
            value="${value:1:${#value}-2}"
        fi

        export "${key}=${value}"
    done < "${env_file}"
}

load_test_environment() {
    load_env_file "${REPO_ROOT}/.env"
    load_env_file "${TESTS_ROOT}/config/testing.env"

    : "${MYSQL_ROOT_PASSWORD:?MYSQL_ROOT_PASSWORD is missing in .env.}"

    TEST_MYSQL_DATABASE="${TEST_MYSQL_DATABASE:-saaster_test_db}"
    TEST_MYSQL_HOST="${TEST_MYSQL_HOST:-${MYSQL_CONTAINER_NAME:-saaster_dev_mysql_host}}"
    TEST_MYSQL_PORT="${TEST_MYSQL_PORT:-3306}"
    TEST_MYSQL_USER="${TEST_MYSQL_USER:-${MYSQL_USER:-mysql_user}}"
    TEST_MYSQL_PASSWORD="${TEST_MYSQL_PASSWORD:-${MYSQL_PASSWORD:-}}"
    TEST_DATASOURCE_NAME="${TEST_DATASOURCE_NAME:-saaster_test}"
    TEST_APP_BASE_URL="${TEST_APP_BASE_URL:-http://127.0.0.1:${LUCEE_PORT:-8080}}"
    TEST_COMPOSE_FILE="${TEST_COMPOSE_FILE:-compose-dev.yml}"
    MYSQL_CONTAINER_NAME="${MYSQL_CONTAINER_NAME:-saaster_dev_mysql_host}"

    export TEST_MYSQL_DATABASE TEST_MYSQL_HOST TEST_MYSQL_PORT TEST_MYSQL_USER \
           TEST_MYSQL_PASSWORD TEST_DATASOURCE_NAME TEST_APP_BASE_URL \
           TEST_COMPOSE_FILE MYSQL_CONTAINER_NAME
}

# Second emergency brake next to the guard in support/test_settings.cfc: no
# script drops or migrates a database that does not carry "test" in its name,
# or that has the same name as the application database.
guard_test_database_name() {
    if [[ "${TEST_MYSQL_DATABASE}" != *test* ]]; then
        echo "Aborted: '${TEST_MYSQL_DATABASE}' is not a test database name." >&2
        exit 1
    fi

    if [[ "${TEST_MYSQL_DATABASE}" == "${MYSQL_DATABASE:-}" ]]; then
        echo "Aborted: the test database has the same name as the application database." >&2
        exit 1
    fi
}

# Docker Desktop does not understand the MSYS paths of Git Bash ("/d/..."), it
# needs "D:/...". 'pwd -W' returns exactly that and only exists there.
host_path() {
    local target="${1}"
    if (cd "${target}" && pwd -W) >/dev/null 2>&1; then
        (cd "${target}" && pwd -W)
    else
        (cd "${target}" && pwd)
    fi
}

require_running_container() {
    local container_name="${1}"
    if ! docker ps --format '{{.Names}}' | grep -qx "${container_name}"; then
        echo "Aborted: container '${container_name}' is not running. Start the dev stack first: docker compose -f ${TEST_COMPOSE_FILE} up -d" >&2
        exit 1
    fi
}
