#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="realsense:latest"
if [[ $# -gt 0 ]]; then
    IMAGE_NAME="$1"
    shift
fi

if [[ $# -gt 0 ]]; then
    CMD=("$@")
else
    CMD=("/bin/bash")
fi

XAUTH=/tmp/.docker.xauth
if [[ ! -f "$XAUTH" ]]; then
    xauth_list=$(xauth nlist "$DISPLAY" 2>/dev/null || true)
    xauth_list=$(sed -e 's/^..../ffff/' <<< "$xauth_list")
    if [[ -n "$xauth_list" ]]; then
        echo "$xauth_list" | xauth -f "$XAUTH" nmerge -
    else
        touch "$XAUTH"
    fi
    chmod a+r "$XAUTH"
fi

docker run -it \
    --rm \
    --name realsense \
    -e DISPLAY \
    -e QT_X11_NO_MITSHM=1 \
    -e XAUTHORITY="$XAUTH" \
    -v "$XAUTH:$XAUTH" \
    -v "/tmp/.X11-unix:/tmp/.X11-unix" \
    -v "/etc/localtime:/etc/localtime:ro" \
    -v "/dev:/dev" \
    --device-cgroup-rule "c 81:* rmw" \
    --device-cgroup-rule "c 189:* rmw" \
    --network host \
    "$IMAGE_NAME" "${CMD[@]}"

# sudo ./run.sh librealsense/librealsense rs-depth
# : sudo ./run.sh realsense:latest rs-enumerate-devices --compact

#sudo ./run.sh and run rs-depth or realsense-viewer


