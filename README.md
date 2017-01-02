ROS GitLab CI
===

[![build status](https://gitlab.com/VictorLamoine/ros_gitlab_ci/badges/master/build.svg)](https://gitlab.com/VictorLamoine/ros_gitlab_ci/commits/master)

[![ROS](http://www.ros.org/wp-content/uploads/2013/10/rosorg-logo1.png)](http://www.ros.org/)

Using Travis CI ? Take a look at [ros-industrial/industrial_ci](https://github.com/ros-industrial/industrial_ci).

Description
---
This repository contains helper scripts and instructions on how to use Continuous Integration (CI) for ROS projects hosted on a GitLab instance.

Supported ROS releases:
- Indigo
- Jade
- Kinetic

This repository uses the [ROS Docker](https://hub.docker.com/_/ros/) images to compile your packages, it does not run tests by default.

How to use
---
Your repository must be hosted on a GitLab instance with CI working and Docker support.

Create a `.gitlab-ci.yml` that looks like [this](/.gitlab-ci.yml):

```xml
image: ros:kinetic-ros-core

variables:
  ROS_PACKAGES_TO_INSTALL: ""

before_script:
 - git clone https://gitlab.com/VictorLamoine/ros_gitlab_ci.git
 - ros_gitlab_ci/gitlab-ci.bash

catkin_make:
  stage: build
  script:
    - catkin_make

catkin_build:
  stage: build
  script:
    - catkin build

```

Commit, push to your repository and watch the pipeline!

