#!/usr/bin/env bash
# Check current and historical snapshot identities without loading credentials.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)/config/backup/borg_common.sh"

digest="sha256:$(printf '%064d' 1)"
warning='Flag --pause has been deprecated, and enabled by default. Use --no-pause to disable pausing during commit.'

for scenario in current docker29_warning empty bare_hash short_hash uppercase wrong_algorithm extra_text unknown_warning duplicate_warning duplicate_id; do
    expected=1
    case "$scenario" in
        current) value="$digest"; expected=0 ;;
        docker29_warning) value="$warning"$'\n'"$digest"; expected=0 ;;
        empty) value='' ;;
        bare_hash) value="${digest#sha256:}" ;;
        short_hash) value='sha256:1234' ;;
        uppercase) value="sha256:$(printf '%064d' 1 | tr 1 A)" ;;
        wrong_algorithm) value="sha512:${digest#sha256:}" ;;
        extra_text) value="$digest unexpected" ;;
        unknown_warning) value='Unexpected Docker output'$'\n'"$digest" ;;
        duplicate_warning) value="$warning"$'\n'"$warning"$'\n'"$digest" ;;
        duplicate_id) value="$digest"$'\n'"$digest" ;;
    esac
    status=0
    normalized="$(snapshot_image_id "$value" 2>/dev/null)" || status=$?
    if { (( expected == 0 )) && { (( status != 0 )) || [[ "$normalized" != "$digest" ]]; }; } ||
        { (( expected != 0 )) && (( status == 0 )); }; then
        echo "Unexpected snapshot identity result: $scenario" >&2
        exit 1
    fi
    echo "PASS: snapshot identity $scenario"
done
