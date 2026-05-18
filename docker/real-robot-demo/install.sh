set -e

# -------------------- ROS2 Jazzy + ros2_control + slam_toolbox + Nav2 + Open RMF --------------------

sudo add-apt-repository universe -y

export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F'"' '{print $4}')
curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb"
sudo dpkg -i /tmp/ros2-apt-source.deb

sudo apt-get update
sudo apt-get install -y ros-dev-tools ros-jazzy-ros-base ros-jazzy-ros2-control ros-jazzy-ros2-controllers ros-jazzy-slam-toolbox ros-jazzy-navigation2 ros-jazzy-nav2-bringup ros-jazzy-rmf-dev

grep -qF "source /opt/ros/jazzy/setup.bash" ~/.bashrc || echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
grep -qF "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" ~/.bashrc || echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc

# -------------------- Libs --------------------

# pigpio
cd ~
wget https://github.com/joan2937/pigpio/archive/master.zip && unzip master.zip
cd ~/pigpio-master
make 
sudo make install

cd ~
sudo rm -rf master.zip pigpio-master

# daemon autostart
sudo tee /etc/systemd/system/pigpiod.service > /dev/null << EOF
[Unit]
Description=pigpiod
After=network.target
[Service]
ExecStart=/usr/local/bin/pigpiod
ExecStop=/usr/bin/killall pigpiod
Type=forking
PIDFile=/run/pigpio.pid
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable pigpiod
sudo systemctl start pigpiod

# ydlidar
sudo apt-get install -y swig

cd ~
git clone https://github.com/xonder05/YDLidar-SDK.git
mkdir ~/YDLidar-SDK/build
cd  ~/YDLidar-SDK/build
cmake .. 
make 
sudo make install

cd ~
rm -rf YDLidar-SDK

# libcamera
sudo apt install -y meson ninja-build libgnutls28-dev libtiff5-dev python3-ply v4l-utils

cd ~
git clone https://github.com/raspberrypi/libcamera.git
cd libcamera
meson setup build --buildtype=release \
  -Dpipelines=rpi/vc4 \
  -Dipas=rpi/vc4 \
  -Dv4l2=true \
  -Dtest=false \
  -Dlc-compliance=disabled \
  -Dcam=disabled \
  -Dqcam=disabled \
  -Ddocumentation=disabled \
  -Dpycamera=enabled

ninja -C build
sudo ninja -C build install

cd ~
rm -rf libcamera

grep -qF "export PYTHONPATH=/usr/local/lib/python3/dist-packages:\$PYTHONPATH" ~/.bashrc || echo "export PYTHONPATH=/usr/local/lib/python3/dist-packages:\$PYTHONPATH" >> ~/.bashrc

# picamera2
sudo apt-get install -y python3-pip
pip install --break-system-packages picamera2

cd ~/.local/lib/python3.12/site-packages/picamera2
sed -i "s/from picamera2\.previews import DrmPreview, NullPreview, QtGlPreview, QtPreview/from picamera2\.previews import NullPreview, QtGlPreview, QtPreview"/ ./picamera2.py
sed -i "/DRM = DrmPreview/d" ./picamera2.py
sed -i "/from .drm_preview import DrmPreview/d" ./previews/__init__.py

# -------------------- waferbot_ros2_ws + node_manager --------------------

# for camera, imu, fuzzy
sudo apt install -y python3-smbus
pip install --break-system-packages picamera2 mpu6050-raspberrypi transforms3d simpful

# for pca9685_ros2_control
sudo apt-get install -y libi2c-dev libncurses-dev

# for node_manager
sudo apt-get install -y libboost-json-dev libboost-thread-dev

cd ~
git clone --recurse-submodules https://github.com/xonder05/waferbot_ros2_ws.git
cd ~/waferbot_ros2_ws/src
git clone https://github.com/xonder05/node_manager.git
cd ~/waferbot_ros2_ws

source /opt/ros/jazzy/setup.bash
colcon build
echo "source ~/waferbot_ros2_ws/install/setup.bash" >> ~/.bashrc

# serial port alias for lidar
chmod 0777 ./src/lib/ydlidar_ros2_driver/startup/initenv.sh 
sudo ./src/lib/ydlidar_ros2_driver/startup/initenv.sh
