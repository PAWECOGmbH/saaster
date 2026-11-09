#!/usr/bin/env bash
#
# Drops the test database and creates it again, empty. Only ever touches the
# test database, never MYSQL_DATABASE from the .env.

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

load_test_environment
guard_test_database_name
require_running_container "${MYSQL_CONTAINER_NAME}"

# Repair stale InnoDB full-text indexes after repeated fixture insert/delete runs,
# without dropping the database or touching development data.
case "${1:-}" in
    --rebuild-search-index)
        printf 'ALTER TABLE `%s`.`customers` ENGINE=InnoDB;\n' "${TEST_MYSQL_DATABASE}" | \
            docker exec -i "${MYSQL_CONTAINER_NAME}" mysql -u root --password="${MYSQL_ROOT_PASSWORD}"
        echo "Customer search index rebuilt in '${TEST_MYSQL_DATABASE}'."
        exit 0
        ;;
    "") ;;
    *) echo "Usage: $0 [--rebuild-search-index]" >&2; exit 2 ;;
esac

# Character set as in V9__change-collation-to-unicode.sql. The migrations set it
# for the tables anyway, this is about the database itself.
sql="DROP DATABASE IF EXISTS \`${TEST_MYSQL_DATABASE}\`;
CREATE DATABASE \`${TEST_MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON \`${TEST_MYSQL_DATABASE}\`.* TO '${TEST_MYSQL_USER}'@'%';
FLUSH PRIVILEGES;"

printf '%s\n' "${sql}" | docker exec -i "${MYSQL_CONTAINER_NAME}" \
    mysql -u root --password="${MYSQL_ROOT_PASSWORD}"

echo "Test database '${TEST_MYSQL_DATABASE}' recreated."
