#!/usr/bin/env bash
set -e

# Source ROS 2 environment
if [ -f "/opt/ros/jazzy/setup.bash" ]; then
  source "/opt/ros/jazzy/setup.bash"
fi

# Source workspace overlay if present
if [ -f "/ws/install/setup.bash" ]; then
  source "/ws/install/setup.bash"
fi

# Best-effort rosdep update (non-fatal)
if command -v rosdep >/dev/null 2>&1; then
  rosdep update >/dev/null 2>&1 || true
fi

exec "$@"

