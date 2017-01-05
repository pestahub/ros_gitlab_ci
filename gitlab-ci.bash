#!/bin/bash

# https://docs.gitlab.com/ce/ci/variables/README.html

# Manage self testing
#--------------------
if [ ${CI_PROJECT_NAME} == "ros_gitlab_ci" ]; then
  echo "##############################################"
  SELF_TESTING="true"

  # Delete sub ROS GitLab CI repository
  rm -r $CI_PROJECT_DIR/$CI_PROJECT_NAME

  # We create a package beginner_tutorials so that the catkin workspace is not empty
  mkdir -p $CI_PROJECT_DIR/catkin_workspace/src
  cd $CI_PROJECT_DIR/catkin_workspace/src
  catkin_create_pkg beginner_tutorials std_msgs rospy roscpp
  cd $CI_PROJECT_DIR/catkin_workspace
  echo "##############################################"

  # Source the gitlab-ros script from the sub GitLab repository
  # This repository has the right branch
  source $CI_PROJECT_DIR/gitlab-ros.bash
else
  source ros_gitlab_ci/gitlab-ros.bash
fi

