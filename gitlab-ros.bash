#!/bin/bash

# Determine ROS_DISTRO
#---------------------
ROS_DISTRO=$(ls /opt/ros/)

if [[ -z "${ROS_DISTRO}" ]]; then
  echo "No ROS distribution was found in /opt/ros/. Aborting!"
  exit 1
fi

# If distro is noetic, use python3 packages
catkin_tools_pkg_name="python-catkin-tools"
catkin_lint_pkg_name="python-catkin-lint"
wstool_pkg_name="python-wstool"
rosdep_pkg_name="python-rosdep"
pip_pkg_name="python-pip"
if [[ "${ROS_DISTRO}" == "noetic" ]]; then
  echo "Noetic: using python 3 packages"
  catkin_tools_pkg_name="python3-catkin-tools"
  catkin_lint_pkg_name="python3-catkin-lint"
  wstool_pkg_name="python3-wstool"
  rosdep_pkg_name="python3-rosdep"
  pip_pkg_name="python3-pip"

  # Fixes https://github.com/catkin/catkin_tools/issues/594
  apt-get install -qq $pip_pkg_name
  pip3 install osrf-pycommon
fi

# Source ROS
#-----------
source /opt/ros/${ROS_DISTRO}/setup.bash

# Install catkin tools and catkin lint
# https://catkin-tools.readthedocs.io/en/latest/installing.html
# xterm helps avoid warnings in the log
#---------------------
apt-get install -qq $catkin_tools_pkg_name $catkin_lint_pkg_name xterm
export TERM="xterm"

# Display system information
#---------------------------
echo "##############################################"
uname -a
lsb_release -a
gcc --version
echo "CXXFLAGS = ${CXXFLAGS}"
cmake --version
echo "##############################################"

# Self testing
#-------------
if [[ "${SELF_TESTING}" == "true" ]]; then
  # We are done, no need to prepare the build
  return
fi

# Prepare build
#--------------
# https://docs.gitlab.com/ce/ci/variables/README.html#predefined-variables-environment-variables

# Does this project have a wstool install file?
rosinstall_files=$(find ${CI_PROJECT_DIR} -maxdepth 2 -type f -name "*.rosinstall")

cd ${CI_PROJECT_DIR}/..
rm -rf catkin_workspace/src
mkdir -p catkin_workspace/src

if [[ -z "${rosinstall_files}" ]]; then
  # No rosinstall file
  # Copy current directory into a src directory
  # Don't move the original clone or GitLab CI fails!
  cp -r ${CI_PROJECT_DIR} catkin_workspace/src/
else
  echo "Using wstool file ${rosinstall_files}"

  # Install wstool
  apt-get install -qq $wstool_pkg_name
  # Create workspace
  cd catkin_workspace
  wstool init src

  while : ; do
    rosinstall_files=$(find ${CI_PROJECT_DIR} -maxdepth 2 -type f -name "*.rosinstall")
    rosinstall_file=$(echo ${rosinstall_files} | cut -d ' ' -f 1)
    if [[ -z "${rosinstall_file}" ]]; then
      break
    fi
    # Use GitLab CI tokens if required by the user
    # This allows to clone private repositories using wstool
    # Requires GitLab 8.12 and that the private repositories are on the same GitLab server
    if [[ "${ROSINSTALL_CI_JOB_TOKEN}" == "true" ]]; then
      echo "Modify rosinstall file to use GitLab CI job token"
      ${ROS_GITLAB_CI_HOME_DIR}/rosinstall_ci_job_token.bash ${rosinstall_file}
    fi
    wstool merge ${rosinstall_file} -t src -y
    rm ${rosinstall_file}
    wstool update -t src || true
  done

  if [[ "${WSTOOL_RECURSIVE}" == "true" ]]; then
    echo "Using wstool recursively"
    while : ; do
      rosinstall_files=$(find src -type f -name "*?.rosinstall")
      rosinstall_file=$(echo ${rosinstall_files} | cut -d ' ' -f 1)
      if [[ -z "${rosinstall_file}" ]]; then
        break
      fi
      if [[ "${ROSINSTALL_CI_JOB_TOKEN}" == "true" ]]; then
        ${ROS_GITLAB_CI_HOME_DIR}/rosinstall_ci_job_token.bash ${rosinstall_file}
      fi
      wstool merge ${rosinstall_file} -t src -y
      rm ${rosinstall_file}
      wstool update -t src || true
    done

    wstool update -t src || true
  fi

  # If the project itself is not included in rosinstall file, copy it manually
  if [ ! -d "src/${CI_PROJECT_NAME}" ]; then
    cp -r ${CI_PROJECT_DIR} src
  fi
fi

# Move catkin workspace to the project directory. Potentially merges with build artifacts that are already in-place.
# Preparation: Remove potentially existing catkin_workspace sub-dir that we also copied over. Could happen if it was part of the build artifacts.
rm -rf ${CI_PROJECT_DIR}/../catkin_workspace/src/${CI_PROJECT_NAME}/catkin_workspace
# Prepation: install rsync
apt-get install -qq rsync
# Actual move: Use rsync for the move because it merges sub-dir and mv does not.
rsync -a ${CI_PROJECT_DIR}/../catkin_workspace ${CI_PROJECT_DIR}

# Initialize git submodules
cd ${CI_PROJECT_DIR}/catkin_workspace/src
for i in */.git; do
  cd "$i/..";
  git submodule init
  git submodule update
  cd -
done
cd ${CI_PROJECT_DIR}/catkin_workspace/

if [[ ("${USE_ROSDEP}" != false && ! -z "${USE_ROSDEP}") || -z "${USE_ROSDEP}" ]]; then
  echo "Using rosdep to install dependencies"
  # Install rosdep and initialize
  apt-get install -qq $rosdep_pkg_name $pip_pkg_name
  rosdep init || true
  rosdep update

  # Use rosdep to install dependencies
  rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y --as-root apt:false
fi
