#!/usr/bin/env bash
set -euo pipefail
exec bash "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/restore_borg.sh" "$@"
