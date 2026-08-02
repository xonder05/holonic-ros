# Holonic-ROS
Holonic-ROS is an overarching name for a combination of four other tools. 
Their combined goal is to enhance orchestration capabilities of ROS2. 
The resulting tool allows you to control ROS2 systems, that can span over multiple physical robots, from a single place, via a user friendly interface.
Links to the individual parts can be found in the `src` folder.

- `node_manager` - A server application that handles management of ROS2 nodes on a remote device.
- `ros2_interface_api` - A bridge application that allows communication between ROS2 and WebSocket. Part of the bridge is a configuration JavaScript library.
- `node-red-ros2-orchestrator` - A Node-RED module that contains new nodes and plugins required for interacting with ROS2.
- `waferbot_ros2_ws` - An example ROS2 system.

## Usage
The `docker` folder contains two examples and an installation script. 

### holonic-ros-tool
This image contains everything needed to run the Node-RED orchestration part, including bridge to ROS2.
- On your device run: `docker compose -f ./docker/holonic-ros-tool/compose.yaml up -d && docker compose -f ./docker/holonic-ros-tool/compose.yaml attach holonic-ros-tool`
- In the container run: `node-red`
- Open browser to `127.0.0.1:1880/`

### sim-robot-demo
This image contains everything to run the example robot in a simulation.
- On your device run: `docker compose -f ./docker/sim-robot-demo/compose.yaml up -d && docker compose -f ./docker/sim-robot-demo/compose.yaml attach sim-robot-demo`
- In the container run: `ros2 launch node_manager node_manager_launch.py`

### real-robot-demo:
Only useful if you have the actual physical robot. 
- Flash Ubuntu Server 24.04 onto SD-Card.
- SSH into RPI
- Copy and run `install.sh` 
    - the installation takes around two hours
    - it will ask for sudo password multiple times throughout the installation
- run `ros2 launch node_manager node_manager_launch.py`
