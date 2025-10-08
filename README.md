# Intel Realsense for ROS2

- [IntelRealSense](https://github.com/IntelRealSense/realsense-ros?tab=readme-ov-file)
---

## Build Docker

```bash
sudo ./build.sh
```

## Run Docker

```bash
sudo ./run.sh
```


## Run ROS 2 interface

```bash
# in the container
source /opt/ros/humble/setup.bash

ros2 launch realsense2_camera rs_launch.py pointcloud.enable:=true
```
