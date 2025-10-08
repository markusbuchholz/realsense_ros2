ARG BASE_IMAGE=ubuntu:20.04 
#################################
#   Librealsense Builder Stage  #
#################################
FROM $BASE_IMAGE AS librealsense-builder

ARG LIBRS_VERSION=2.55.1
# Ensure librealsense version is set (can be overridden at build time)
RUN test -n "$LIBRS_VERSION"

# To avoid waiting for input during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Builder dependencies installation
RUN apt-get update \
    && apt-get install -qq -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    build-essential \
    cmake \
    libssl-dev \
    libusb-1.0-0-dev \
    pkg-config \
    libgtk-3-dev \
    libglfw3-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    qtbase5-dev \
    qtbase5-dev-tools \
    qtdeclarative5-dev \
    qtquickcontrols2-5-dev \
    qttools5-dev \
    qttools5-dev-tools \
    qtchooser \
    qt5-qmake \
    qtmultimedia5-dev \
    libqt5serialport5-dev \
    libqt5svg5-dev \
    libqt5opengl5-dev \
    curl \
    python3 \
    python3-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download sources
WORKDIR /usr/src
RUN curl https://codeload.github.com/IntelRealSense/librealsense/tar.gz/refs/tags/v$LIBRS_VERSION -o librealsense.tar.gz 
RUN tar -zxf librealsense.tar.gz \
    && rm librealsense.tar.gz 
RUN ln -s /usr/src/librealsense-$LIBRS_VERSION /usr/src/librealsense

# Build and install
RUN cd /usr/src/librealsense \
    && mkdir build && cd build \
    && cmake \
    -DCMAKE_C_FLAGS_RELEASE="${CMAKE_C_FLAGS_RELEASE} -s" \
    -DCMAKE_CXX_FLAGS_RELEASE="${CMAKE_CXX_FLAGS_RELEASE} -s" \
    -DCMAKE_INSTALL_PREFIX=/opt/librealsense \    
    -DBUILD_EXAMPLES=ON \
    -DBUILD_GRAPHICAL_EXAMPLES=ON \
    -DBUILD_TOOLS=ON \
    -DBUILD_PYTHON_BINDINGS:bool=true \
    -DPYTHON_EXECUTABLE=/usr/bin/python3 \
    -DCMAKE_BUILD_TYPE=Release ../ \
    && make -j$(($(nproc)-1)) all \
    && make install 

######################################
#   librealsense Base Image Stage    #
######################################
FROM ${BASE_IMAGE} AS librealsense

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    ROS_DISTRO=foxy

# Copy binaries from builder stage
COPY --from=librealsense-builder /opt/librealsense /usr/local/
COPY --from=librealsense-builder /usr/lib/python3/dist-packages/pyrealsense2 /usr/lib/python3/dist-packages/pyrealsense2
COPY --from=librealsense-builder /usr/src/librealsense/config/99-realsense-libusb.rules /etc/udev/rules.d/
COPY --from=librealsense-builder /usr/src/librealsense/config/99-realsense-d4xx-mipi-dfu.rules /etc/udev/rules.d/
ENV PYTHONPATH=/usr/local/lib

# Install dep packages
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    libusb-1.0-0 \
    udev \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    git \
    libgtk-3-0 \
    libglfw3 \
    libgl1 \
    libglu1-mesa \
    libopengl0 \
    libgl1-mesa-dri \
    libqt5core5a \
    libqt5gui5 \
    libqt5widgets5 \
    libqt5opengl5 \
    libqt5svg5 \
    libqt5multimedia5 \
    libqt5multimediawidgets5 \
    libqt5serialport5 \
    libqt5x11extras5 \
    libgstreamer1.0-0 \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-tools \
    gstreamer1.0-gl \
    gstreamer1.0-qt5 \
    mesa-utils \
    locales \
    gnupg2 \
    lsb-release \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | apt-key add - \
    && echo "deb [arch=amd64] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    ros-foxy-desktop \
    python3-colcon-common-extensions \
    && rm -rf /var/lib/apt/lists/* \
    && (dpkg-reconfigure --frontend noninteractive tzdata || true)

RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /etc/bash.bashrc

# Shows a list of connected Realsense devices
CMD [ "rs-enumerate-devices", "--compact" ]
