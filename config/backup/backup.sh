#!/usr/bin/env bash
# Compatibility entry point; existing backup cron commands now use Borg.
set -euo pipefail
if (( $# == 0 )); then set -- --backup; fi
exec bash "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/backup_borg.sh" "$@"
