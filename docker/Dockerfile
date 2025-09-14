FROM osrf/ros:jazzy-desktop

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-colcon-common-extensions \
    python3-rosdep \
    build-essential \
    git \
 && rm -rf /var/lib/apt/lists/*

# Initialize rosdep (idempotent)
RUN rosdep init 2>/dev/null || true

WORKDIR /ws

# Lightweight entrypoint that sources ROS and workspace overlays
COPY docker/entrypoint.sh /ros_entrypoint.sh
RUN chmod +x /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

