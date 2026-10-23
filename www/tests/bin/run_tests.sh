#!/usr/bin/env bash
#
# Calls the TestBox runner over HTTP. JSON by default, so the output stays
# machine-readable in the shell.
#
#   bash www/tests/bin/run_tests.sh
#   bash www/tests/bin/run_tests.sh "reporter=mintext"
#   bash www/tests/bin/run_tests.sh "reporter=mintext&directory=tests.specs.unit"
#   bash www/tests/bin/run_tests.sh "reporter=mintext&bundles=tests.specs.unit.global_spec"

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

load_test_environment

query_string="${1:-reporter=json}"
header_file="$(mktemp)"
trap 'rm -f "${header_file}"' EXIT

# The test application keeps the Saaster objects in the application scope -
# instances built at start-up. A change to a .cfc would not be visible without a
# restart, and the run would stay green while testing the old version. Hence a
# reinit before every run. Only the test application is affected, the running
# app under / is not.
curl --silent --show-error --output /dev/null \
    "${TEST_APP_BASE_URL}/tests/healthcheck.cfm?reinit=1" || true

curl --fail --silent --show-error \
    --dump-header "${header_file}" \
    --header "Accept: application/json" \
    "${TEST_APP_BASE_URL}/tests/runner.cfm?${query_string}"

echo

# TestBox puts the counters into the response headers itself. This is the only
# evaluation that is independent of the chosen reporter - and without an exit
# code a red run would end with 0 just like a green one, which makes it useless
# in a pipeline or a git hook.
read_counter() {
    local counter_name="${1}"
    local value
    value="$(grep -i "^x-testbox-${counter_name}:" "${header_file}" | tail -1 | tr -d '\r' | cut -d' ' -f2-)"
    printf '%s' "${value:-0}"
}

failed="$(read_counter totalFail)"
errored="$(read_counter totalError)"

if [[ "${failed}" != "0" || "${errored}" != "0" ]]; then
    echo "Failed: ${failed}, errors: ${errored}" >&2
    exit 1
fi
