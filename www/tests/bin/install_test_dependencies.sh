#!/usr/bin/env bash
#
# Installs the TestBox version pinned in box.json into vendor/.
#
# Deliberately through a throwaway CommandBox container: no developer needs a
# globally installed 'box', and the version lives in box.json only.

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

# MSYS_NO_PATHCONV: Git Bash on Windows treats '/workspace' as a path and turns
# it into 'C:/Program Files/Git/workspace'. With the conversion switched off,
# the host path must be passed in Windows notation instead - hence host_path().
MSYS_NO_PATHCONV=1 docker run --rm \
    --volume "$(host_path "${TESTS_ROOT}"):/workspace" \
    --workdir /workspace \
    ortussolutions/commandbox:latest \
    box install --production "$@"

echo "TestBox installed in ${TESTS_ROOT}/vendor/testbox."
