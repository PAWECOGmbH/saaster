#!/usr/bin/env bash
#
# Applies the productive migrations from config/db (core, then myapp) to the
# test database - with the same Flyway service and history tables as the
# development database (flyway_core, flyway_myapp).

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

load_test_environment
guard_test_database_name
require_running_container "${MYSQL_CONTAINER_NAME}"

cd "${REPO_ROOT}"

for folder in core myapp; do
    [[ -d "config/db/${folder}" ]] || continue

    echo "Migrating '${folder}' into '${TEST_MYSQL_DATABASE}'..."

    # FLYWAY_DB_FOLDER selects the mounted migration folder in compose-dev.yml.
    # '--no-deps' matters: without it 'docker compose run' recreates the
    # dependent services and restarts the running dev stack. MSYS_NO_PATHCONV
    # stops Git Bash on Windows from rewriting '/flyway/...' into a Windows path.
    FLYWAY_DB_FOLDER="${folder}" MSYS_NO_PATHCONV=1 \
    docker compose -f "${TEST_COMPOSE_FILE}" run --rm --no-deps flyway \
        -url="jdbc:mysql://${TEST_MYSQL_HOST}:${TEST_MYSQL_PORT}/${TEST_MYSQL_DATABASE}?useSSL=false&allowPublicKeyRetrieval=true" \
        -locations="filesystem:/flyway/${folder}" \
        -table="flyway_${folder}" \
        -baselineOnMigrate=true \
        migrate
done

echo "Migrations applied to '${TEST_MYSQL_DATABASE}'."
