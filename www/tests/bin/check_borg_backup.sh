#!/usr/bin/env bash
# Run real encrypted Borg backups and a destructive restore on disposable test data only.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
cd "$REPO_ROOT"
export MSYS_NO_PATHCONV=1
if [[ -n "${DOCKER_CONTEXT:-}" ]]; then
    endpoint="$(docker context inspect "$DOCKER_CONTEXT" --format '{{.Endpoints.docker.Host}}')"
elif [[ -n "${DOCKER_HOST:-}" ]]; then
    endpoint="$DOCKER_HOST"
else
    endpoint="$(docker context inspect --format '{{.Endpoints.docker.Host}}')"
fi
case "$endpoint" in
    npipe://*) socket=/var/run/docker.sock ;;
    unix://*) socket="${endpoint#unix://}" ;;
    *) echo "Refusing a non-local Docker endpoint: $endpoint" >&2; exit 1 ;;
esac
[[ "$(docker info --format '{{.OSType}}')" == linux ]] || { echo 'A local Linux Docker engine is required.' >&2; exit 1; }
project="saaster-borg-test-$(date -u +%Y%m%d%H%M%S)-$$"
workspace="$project-workspace"
repository="$project-repository"
controller="$project-controller"
tools_image="$project-tools:local"
fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/saaster-borg-test.XXXXXX")"
cleanup() {
    local result=$?
    trap - EXIT
    docker rm -f "$controller" >/dev/null 2>&1 || true
    local id
    while IFS= read -r id; do [[ -z "$id" ]] || docker rm -f "$id" >/dev/null; done < <(docker ps -aq --filter "label=com.docker.compose.project=$project")
    while IFS= read -r id; do [[ -z "$id" ]] || docker volume rm "$id" >/dev/null; done < <(docker volume ls -q --filter "label=com.docker.compose.project=$project")
    while IFS= read -r id; do [[ -z "$id" ]] || docker network rm "$id" >/dev/null; done < <(docker network ls -q --filter "label=com.docker.compose.project=$project")
    docker volume rm "$workspace" "$repository" >/dev/null 2>&1 || true
    while IFS= read -r id; do [[ -z "$id" ]] || docker image rm "$id" >/dev/null; done < <(docker image ls --format '{{.Repository}}:{{.Tag}}' --filter "reference=saaster-borg-snapshot/$project:*")
    docker image rm "$tools_image" >/dev/null 2>&1 || true
    case "$fixture_root" in "${TMPDIR:-/tmp}"/saaster-borg-test.*) rm -rf -- "$fixture_root" ;; esac
    exit "$result"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
# Only Git-visible source files enter the Linux workspace. Local configuration,
# vendor dependencies, logs, todo.md and credentials are never copied.
if [[ -n "$(git ls-files -- .env www/config.cfm www/tests/config/testing.json)" ]]; then
    echo 'Local configuration must not be tracked.' >&2
    exit 1
fi
git ls-files -z --cached --others --exclude-standard | while IFS= read -r -d '' path; do
    if [[ -f "$path" || -L "$path" ]]; then printf '%s\0' "$path"; fi
done | tar --null -T - -cf "$fixture_root/source.tar"
docker build --quiet -t "$tools_image" "$(host_path "$TESTS_ROOT/backup")"
docker volume create --label "org.saaster.borg.test=$project" "$workspace" >/dev/null
docker volume create --label "org.saaster.borg.test=$project" "$repository" >/dev/null
mountpoint="$(docker volume inspect --format '{{.Mountpoint}}' "$workspace")"
[[ "$mountpoint" == /* && "$mountpoint" != / ]] || { echo 'Invalid workspace mountpoint.' >&2; exit 1; }
# The same Linux path exists in the controller and daemon, so Compose bind
# mounts point at this disposable volume, including on Docker Desktop.
docker create --name "$controller" --network none \
    --mount "type=volume,src=$workspace,dst=$mountpoint" \
    --mount "type=volume,src=$repository,dst=/borg-test" \
    --mount "type=bind,src=$socket,dst=/var/run/docker.sock" \
    --workdir "$mountpoint/project" -e "SAASTER_BORG_TEST_PROJECT=$project" "$tools_image" -c '
        set -e
        tar -xf /tmp/source.tar -C "$PWD"
        rm /tmp/source.tar
        find config/backup www/tests/backup -type f -name "*.sh" -exec sed -i "s/\r$//" {} +
        exec bash www/tests/backup/roundtrip.sh
    ' >/dev/null
docker cp "$(host_path "$fixture_root")/source.tar" "$controller:/tmp/source.tar"
docker start -a "$controller"
status="$(docker inspect --format '{{.State.ExitCode}}' "$controller")"
[[ "$status" == 0 ]] || exit "$status"
