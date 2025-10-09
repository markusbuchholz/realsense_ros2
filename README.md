# Intel Realsense for ROS2

- [IntelRealSense](https://github.com/IntelRealSense/realsense-ros?tab=readme-ov-file)
- [Intel Docs](https://amrdocs.intel.com/docs/2.2/index.html)
- [ORB_SLAM3](https://github.com/UZ-SLAMLab/ORB_SLAM3)
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
