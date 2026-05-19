# Holonic ROS

### holonic-ros-tool
- On your device run: `docker compose -f ./docker/holonic-ros-tool/compose.yaml up -d && docker compose -f ./docker/holonic-ros-tool/compose.yaml attach holonic-ros-tool`
- In the container run: `node-red`
- Open browser to `127.0.0.1:1880/`

### sim-robot-demo
- On your device run: `docker compose -f ./docker/sim-robot-demo/compose.yaml up -d && docker compose -f ./docker/sim-robot-demo/compose.yaml attach sim-robot-demo`
- In the container run: `ros2 launch node_manager node_manager_launch.py`

### real-robot-demo:
- Flash Ubuntu Server 24.04 onto SD-Card.
- SSH into RPI
- copy and run `install.sh` 
    - the installation takes around two hours
    - it will ask for sudo password multiple times throughout the installation
- run `ros2 launch node_manager node_manager_launch.py`
