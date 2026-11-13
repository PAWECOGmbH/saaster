#!/usr/bin/env bash
# Exercise the real runner's exit status without Docker, a database or HTTP.
set -euo pipefail
test_bin_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/saaster-runner-check.XXXXXX")"
cleanup() {
    case "${fixture_root}" in
        "${TMPDIR:-/tmp}"/saaster-runner-check.*) rm -rf -- "${fixture_root}" ;;
        *) echo "Refusing unexpected fixture cleanup path." >&2 ;;
    esac
}
trap cleanup EXIT
mkdir "${fixture_root}/bin"
cat > "${fixture_root}/bin/curl" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
header_file=""
url=""
while (( $# )); do
    case "$1" in
        --dump-header) header_file="$2"; shift 2 ;;
        http*) url="$1"; shift ;;
        *) shift ;;
    esac
done
if [[ "${url}" == *healthcheck.cfm* ]]; then
    [[ "${RUNNER_CASE}" != health_error ]] || exit 22
    exit 0
fi
touch "${RUNNER_MARKER}"
[[ "${RUNNER_CASE}" != http_error ]] || exit 22
total=2; passed=2; failed=0; errored=0; skipped=0
case "${RUNNER_CASE}" in
    failed) passed=1; failed=1 ;;
    errored) passed=1; errored=1 ;;
    invalid) failed=invalid ;;
    zero) total=0; passed=0 ;;
    all_skipped) passed=0; skipped=2 ;;
    inconsistent) total=3 ;;
esac
{
    printf 'HTTP/1.1 200 OK\r\n'
    printf 'x-testbox-totalSpecs: %s\r\n' "${total}"
    printf 'x-testbox-totalPass: %s\r\n' "${passed}"
    [[ "${RUNNER_CASE}" == missing ]] || printf 'x-testbox-totalFail: %s\r\n' "${failed}"
    printf 'x-testbox-totalError: %s\r\n' "${errored}"
    printf 'x-testbox-totalSkipped: %s\r\n' "${skipped}"
    [[ "${RUNNER_CASE}" != duplicate ]] || printf 'x-testbox-totalFail: 0\r\n'
    [[ "${RUNNER_CASE}" != stale_headers ]] || printf '\r\nHTTP/1.1 302 Found\r\n'
    printf '\r\n'
} > "${header_file}"
printf 'stub reporter output\n'
STUB
chmod +x "${fixture_root}/bin/curl"

for scenario in passed failed errored health_error http_error missing invalid zero all_skipped inconsistent duplicate stale_headers; do
    marker="${fixture_root}/${scenario}.called"
    status=0
    PATH="${fixture_root}/bin:${PATH}" MYSQL_ROOT_PASSWORD=runner-contract-test \
        RUNNER_CASE="${scenario}" RUNNER_MARKER="${marker}" \
        bash "${test_bin_dir}/run_tests.sh" 'reporter=mintext' > "${fixture_root}/${scenario}.log" 2>&1 || status=$?
    if [[ "${scenario}" == passed ]]; then
        expected=0
    else
        expected=1
    fi
    if { (( expected == 0 && status != 0 )); } || { (( expected == 1 && status == 0 )); }; then
        cat "${fixture_root}/${scenario}.log" >&2
        echo "Unexpected runner status for ${scenario}: ${status}" >&2
        exit 1
    fi
    if [[ "${scenario}" == health_error && -e "${marker}" ]]; then
        echo "Tests started despite a failed healthcheck." >&2
        exit 1
    fi
    echo "PASS: ${scenario}"
done
