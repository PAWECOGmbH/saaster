#!/usr/bin/env bash
#
# Builds the test environment from scratch: configuration, empty database,
# migrations. There is no seed on purpose - every spec creates the data it
# needs through support/fixtures.cfc and removes it again.

set -euo pipefail

TEST_BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "${TEST_BIN_DIR}/write_test_config.sh"
bash "${TEST_BIN_DIR}/reset_test_db.sh"
bash "${TEST_BIN_DIR}/migrate_test_db.sh"

echo "Test environment ready."
