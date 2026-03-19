#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="sandbox"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIR_NAME="$(basename "$(pwd)")"
CONTAINER_NAME="sandbox-$(echo "$DIR_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g')"

usage() {
    echo "Usage: sandbox [init|start|enter|stop|rebuild|list|remove <name>]"
    echo "       sandbox -d    (with Docker socket access)"
}

build() {
    echo "Building sandbox image..."
    local github_token="${GITHUB_TOKEN:-$(gh auth token 2>/dev/null || true)}"
    if [ -n "$github_token" ]; then
        GITHUB_TOKEN="$github_token" docker build \
            --secret id=github_token,env=GITHUB_TOKEN \
            -t "$IMAGE_NAME" "$SCRIPT_DIR"
    else
        echo "⚠ No GitHub token found — build may hit rate limits"
        docker build -t "$IMAGE_NAME" "$SCRIPT_DIR"
    fi
}

start() {
    local docker_socket=false
    if [ "${1:-}" = "-d" ]; then
        docker_socket=true
    fi

    if ! docker image inspect "$IMAGE_NAME" &>/dev/null; then
        build
    fi

    if docker container inspect "$CONTAINER_NAME" &>/dev/null; then
        if [ "$(docker container inspect -f '{{.State.Running}}' "$CONTAINER_NAME")" = "true" ]; then
            return 0
        fi
        docker start "$CONTAINER_NAME" >/dev/null
    else
        local mounts=(
            -v "$(pwd):/workspace"
        )

        if [ "$docker_socket" = true ]; then
            mounts+=(-v /var/run/docker.sock:/var/run/docker.sock)
            echo "⚠ Docker socket mounted — container has host-level access"
        fi

        [ -d "$HOME/.claude" ] && mounts+=(-v "$HOME/.claude:/root/.claude")
        [ -d "$HOME/.codex" ] && mounts+=(-v "$HOME/.codex:/root/.codex")
        [ -d "$HOME/.gemini" ] && mounts+=(-v "$HOME/.gemini:/root/.gemini")
        [ -f "$HOME/.gitconfig" ] && mounts+=(-v "$HOME/.gitconfig:/root/.gitconfig:ro")

        # Mount dotfiles repo so symlinked skills/commands resolve inside container
        local dotfiles_dir
        dotfiles_dir="$(dirname "$SCRIPT_DIR")"
        mounts+=(-v "$dotfiles_dir:$dotfiles_dir:ro")

        echo "Creating sandbox for $DIR_NAME..."
        docker run -d \
            --name "$CONTAINER_NAME" \
            --hostname "$DIR_NAME" \
            --network host \
            -e TERM="${TERM:-xterm-256color}" \
            "${mounts[@]}" \
            "$IMAGE_NAME" \
            sleep infinity >/dev/null
    fi
}

enter() {
    docker exec -it "$CONTAINER_NAME" zsh
}

stop() {
    docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1
    echo "Stopped $CONTAINER_NAME"
}

remove() {
    local target="${1:-$CONTAINER_NAME}"
    [[ "$target" != sandbox-* ]] && target="sandbox-$target"
    docker rm -f "$target" >/dev/null 2>&1
    echo "Removed $target"
}

list() {
    docker ps -a --filter "name=sandbox-" --format "table {{.Names}}\t{{.Status}}\t{{.RunningFor}}"
}

case "${1:-}" in
    init)    build ;;
    start)   start ;;
    enter)   enter ;;
    stop)    stop ;;
    list)    list ;;
    remove)  remove "${2:-}" ;;
    rebuild) stop 2>/dev/null || true; build; start; enter ;;
    -d)      start -d; enter ;;
    "")      start; enter ;;
    *)       usage; exit 1 ;;
esac
