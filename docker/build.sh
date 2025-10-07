#!/usr/bin/env bash
set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd "$DIR"

DEFAULT_LIBRS_VERSION="2.55.1"
LIBRS_VERSION="${1:-${LIBRS_VERSION:-${DEFAULT_LIBRS_VERSION}}}"

if [[ "${LIBRS_VERSION}" == "${DEFAULT_LIBRS_VERSION}" ]]; then
    echo "Using default librealsense version ${LIBRS_VERSION}" >&2
else
    echo "Using librealsense version ${LIBRS_VERSION}" >&2
fi

docker build \
    --build-arg LIBRS_VERSION="${LIBRS_VERSION}" \
    -f "$DIR"/Dockerfile \
    -t realsense:latest \
    ..


#docker build --no-cache -f $DIR/Dockerfile -t blueboat_sitl_x:latest ..
