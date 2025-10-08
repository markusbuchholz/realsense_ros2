# ===============================================================
# ROS 2 Humble (OSRF) + librealsense SDK + realsense2_camera + Open3D
# Single-stage; builds librealsense from tag tarball (v<version>)
# Pass LIBRS_VERSION=2.56.5 (default) or another tag number (w/o the 'v')
# ===============================================================

FROM osrf/ros:humble-desktop

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 TZ=Etc/UTC

# -----------------------------
# Dev tools & build deps
# -----------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake git pkg-config curl ca-certificates \
    python3-pip python3-colcon-common-extensions python3-vcstool python3-rosdep \
    libusb-1.0-0-dev libgtk-3-dev libglfw3-dev \
    libgl1-mesa-dev libglu1-mesa-dev libssl-dev udev \
    ros-humble-diagnostic-updater \
    ros-humble-realsense2-camera ros-humble-realsense2-camera-msgs ros-humble-realsense2-description \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Build librealsense (Intel SDK) from a tag tarball
# -----------------------------
WORKDIR /usr/src
ARG LIBRS_VERSION=2.56.5
# Normalize: ensure we download v<version> even if ARG lacks the 'v'
RUN set -eux; \
    TAG="v${LIBRS_VERSION#v}"; \
    curl -fL "https://codeload.github.com/IntelRealSense/librealsense/tar.gz/refs/tags/${TAG}" -o librealsense.tar.gz; \
    tar -zxf librealsense.tar.gz; rm librealsense.tar.gz; \
    ln -s "librealsense-${TAG#v}" librealsense

WORKDIR /usr/src/librealsense/build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release \
             -DBUILD_EXAMPLES=ON \
             -DBUILD_TOOLS=ON \
             -DBUILD_GRAPHICAL_EXAMPLES=OFF \
             -DBUILD_PYTHON_BINDINGS=ON \
             -DPYTHON_EXECUTABLE=/usr/bin/python3 \
 && make -j"$(nproc)" \
 && make install \
 && ldconfig

# udev rules so the camera is recognized in the container (needs --privileged)
RUN cp /usr/src/librealsense/config/99-realsense-libusb.rules /etc/udev/rules.d/ && \
    cp /usr/src/librealsense/config/99-realsense-d4xx-mipi-dfu.rules /etc/udev/rules.d/

# -----------------------------
# Open3D for 3D processing
# -----------------------------
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir open3d

# -----------------------------
# rosdep & environment
# -----------------------------
RUN rosdep init || true && rosdep update || true
RUN bash -lc 'echo "source /opt/ros/humble/setup.bash" >> /etc/bash.bashrc'

WORKDIR /home/dev_ws

# Default action: list cameras (needs --privileged and /dev passthrough)
CMD ["/bin/bash", "-lc", "rs-enumerate-devices --compact || bash"]
