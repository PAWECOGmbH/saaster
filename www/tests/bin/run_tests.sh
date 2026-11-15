#!/usr/bin/env bash
# Calls TestBox over HTTP and rejects failed, empty or unverified results.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
load_test_environment

query_string="${1:-reporter=json}"
header_file="$(mktemp)"
trap 'rm -f "${header_file}"' EXIT

# Follow the reinit redirect so the rebuilt test application must be healthy.
curl --fail --silent --show-error --location --max-redirs 3 \
    --connect-timeout 10 --max-time 180 --output /dev/null \
    "${TEST_APP_BASE_URL}/tests/healthcheck.cfm?reinit=1"

curl --fail --silent --show-error --connect-timeout 10 --max-time 1800 \
    --dump-header "${header_file}" --header "Accept: application/json" \
    "${TEST_APP_BASE_URL}/tests/runner.cfm?${query_string}"
echo

# Read exactly one numeric counter from the final HTTP response. Earlier
# response blocks, missing/duplicate headers and reporter HTML cannot pass.
read_counter() {
    local value
    if ! value="$(awk -v target="x-testbox-${1}" '
        /^HTTP\// { count = 0; value = ""; next }
        {
            sub(/\r$/, "")
            colon = index($0, ":")
            if (colon > 0 && tolower(substr($0, 1, colon - 1)) == tolower(target)) {
                count++
                value = substr($0, colon + 1)
                gsub(/^[ \t]+|[ \t]+$/, "", value)
            }
        }
        END {
            if (count != 1 || value !~ /^[0-9]+$/ || length(value) > 9) exit 1
            print value
        }
    ' "${header_file}")"; then
        echo "Missing or invalid TestBox counter: ${1}" >&2
        return 1
    fi
    printf '%s' "$((10#${value}))"
}

specs="$(read_counter totalSpecs)"
passed="$(read_counter totalPass)"
failed="$(read_counter totalFail)"
errored="$(read_counter totalError)"
skipped="$(read_counter totalSkipped)"

if (( failed > 0 || errored > 0 )); then
    echo "Failed: ${failed}, errors: ${errored}" >&2
    exit 1
fi
if (( specs == 0 || passed == 0 || specs != passed + failed + errored + skipped )); then
    echo "No executed tests or inconsistent TestBox counters." >&2
    exit 1
fi
