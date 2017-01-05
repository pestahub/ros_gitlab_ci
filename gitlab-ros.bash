#!/bin/bash

# Determine ROS_DISTRO
#---------------------
ROS_DISTRO=$(ls /opt/ros/)

if [ -z "$ROS_DISTRO" ]; then
  echo "No ROS distribution was found in /opt/ros/. Aborting!"
  exit -1
fi

# Install gcc g++
#----------------
apt-get update >/dev/null
apt-get install gcc g++

# Source ROS
#-----------
source /opt/ros/$ROS_DISTRO/setup.bash >/dev/null

# Install catkin tools # https://catkin-tools.readthedocs.io/en/latest/installing.html
#---------------------
apt-get install -qq wget >/dev/null
sh -c 'echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list' >/dev/null
wget http://packages.ros.org/ros.key -O - | apt-key add - >/dev/null
apt-get update >/dev/null
apt-get install -qq python-catkin-tools xterm >/dev/null
export TERM=xterm # Makes catkin build output less ugly

# Install ROS packages required by the user
#------------------------------------------
# Split packages into package list
IFS=' ' read -ra PACKAGES <<< "$ROS_PACKAGES_TO_INSTALL"
# Clear packages list
ROS_PACKAGES_TO_INSTALL=""

# Append "ros-kinetic-" (eg for Kinetic) before the package name
# and append in the packages list
for package in "${PACKAGES[@]}"; do
  ROS_PACKAGES_TO_INSTALL="${ROS_PACKAGES_TO_INSTALL} ros-$ROS_DISTRO-$package"
done

# Install the packages
apt-get install -qq $ROS_PACKAGES_TO_INSTALL >/dev/null

# Add color diagnostics
#----------------------
# Don't add if user defined the variable
# Don't add if gcc is too old to support the option

# http://unix.stackexchange.com/questions/285924/how-to-compare-a-programs-version-in-a-shell-script/285928#285928
gcc_version="$(gcc -dumpversion)"
required_ver="4.9.0"
if [ "$(printf "$required_ver\n$gcc_version" | sort -V | head -n1)" == "$gcc_version" ] && [ "$gcc_version" != "$required_ver" ]; then 
  echo "Can't use -fdiagnostics-color, gcc is too old!"
else
  if [ -e ${DISABLE_GCC_COLORS} ]; then
    export CXXFLAGS="$CXXFLAGS -fdiagnostics-color"
  fi
fi

# Enable global C++11 if required by the user
#--------------------------------------------
if [ ! -z ${GLOBAL_C11+x} ]; then
  echo "Enabling C++11 globally"
  export CXXFLAGS="$CXXFLAGS -std=c++11"
fi

# Display system information
#---------------------------
echo "##############################################"
uname -a
lsb_release -a
gcc --version
echo "CXXFLAGS = $CXXFLAGS"
cmake --version
echo "##############################################"

# Self testing
#-------------
if [ "$SELF_TESTING" == "true" ]; then
  # We are done, no need to prepare the build
  return
fi

# Prepare build
#--------------
# https://docs.gitlab.com/ce/ci/variables/README.html#predefined-variables-environment-variables

# Does this project have a wstool install file?
rosinstall_file=$(find $CI_PROJECT_DIR -maxdepth 2 -type f -name "*.rosinstall")

cd $CI_PROJECT_DIR/..
mkdir -p catkin_workspace/src

if [ -z "$rosinstall_file" ]; then
  # No rosinstall file
  # Copy current directory into a src directory
  # Don't move the original clone or GitLab CI fails!
  cp -r $CI_PROJECT_DIR catkin_workspace/src/
else
  echo "Using wstool file $rosinstall_file"
  # Install wstool
  apt-get install -qq python-wstool >/dev/null
  # Create workspace
  cd catkin_workspace
  wstool init src $rosinstall_file
  wstool update -t src
  
  # If the project itself is not included in rosinstall file, copy it manually
  if [ ! -d "src/$CI_PROJECT_NAME" ]; then
    cp -r $CI_PROJECT_DIR src
  fi
fi

mv $CI_PROJECT_DIR/../catkin_workspace $CI_PROJECT_DIR
cd $CI_PROJECT_DIR/catkin_workspace
