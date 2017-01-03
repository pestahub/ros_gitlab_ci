#!/bin/bash

# https://docs.gitlab.com/ce/ci/variables/README.html

# If self testing
#----------------
if [ ${CI_PROJECT_URL} == "https://gitlab.com/VictorLamoine/$CI_PROJECT_NAME" ]; then
  echo "##############################################"
  # Go into the sub ROS GitLab CI repository
  cd $CI_PROJECT_DIR/$CI_PROJECT_NAME

  # Switch to the branch we want to test
  git checkout ${CI_BUILD_REF_NAME} &>/dev/null
  echo "Self testing, ${CI_PROJECT_URL}"
  echo $'Current branch is:\n'"$(git branch)"

  # We create a package beginner_tutorials so that the catkin workspace is not empty
  mkdir $CI_PROJECT_DIR/src
  cd $CI_PROJECT_DIR/src
  catkin_create_pkg beginner_tutorials std_msgs rospy roscpp
  cd $CI_PROJECT_DIR
  echo "##############################################"
fi

# Source the gitlab-ros script from the sub GitLab repository
# This repository has the right branch
source $CI_PROJECT_NAME/gitlab-ros.bash

