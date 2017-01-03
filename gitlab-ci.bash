#!/bin/bash

# If self testing
#----------------
# This happens only if ros_gitlab_ci is testing himself, not in user repositories!
if [ ${CI_PROJECT_URL} == "https://gitlab.com/VictorLamoine/ros_gitlab_ci" ]; then
  echo "##############################################"
  echo "Self testing, ${CI_PROJECT_URL}"
  # Switch to the branch we want to test
  git checkout ${CI_BUILD_REF_NAME}
  echo $'Current branch is:\n'"$(git branch)"

  cd $CI_PROJECT_DIR/src
  # We create a package beginner_tutorials so that the catkin workspace is not empty
  catkin_create_pkg beginner_tutorials std_msgs rospy roscpp
  cd $CI_PROJECT_DIR
  echo "##############################################"
fi

# If self testing, the gitlab-ros.bash script changed compared to when the
# script started because we switched branch!
source gitlab-ros.bash

