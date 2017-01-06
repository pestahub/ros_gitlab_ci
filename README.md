 [![ROS](http://www.ros.org/wp-content/uploads/2013/10/rosorg-logo1.png)](http://www.ros.org/) GitLab CI
===

[![build status](https://gitlab.com/VictorLamoine/ros_gitlab_ci/badges/master/build.svg)](https://gitlab.com/VictorLamoine/ros_gitlab_ci/commits/master)


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

```yml
image: ros:kinetic-ros-core

variables:
  ROS_PACKAGES_TO_INSTALL: ""

before_script:
 - git clone https://gitlab.com/VictorLamoine/ros_gitlab_ci.git
 - source ros_gitlab_ci/gitlab-ci.bash

catkin_make:
  stage: build
  script:
    - catkin_make

catkin_build:
  stage: build
  script:
    - catkin build --summarize --no-status

```
Commit, push to your repository and watch the pipeline!

Useful variables
---
- `ROS_PACKAGES_TO_INSTALL` (empty by default) allows to install extra ROS packages, to install `ros-kinetic-rviz` just add `rviz` to the list, the ROS distro is automatically detected.
- `GLOBAL_C11` (not defined by default) allows to force C++11 for every project compiled, defined it to any value (eg `true`) to globally enable C++11.
- `DISABLE_GCC_COLORS` (false by default) allows to disable gcc colour output ([-fdiagnostics-color](https://gcc.gnu.org/onlinedocs/gcc-4.6.3/gcc/Language-Independent-Options.html))

Installing extra APT packages
---
Just add them after launching `gitlab-ci.bash` in the `before_script` section, for example:

```yml
before_script:
 - git clone https://gitlab.com/VictorLamoine/ros_gitlab_ci.git
 - source ros_gitlab_ci/gitlab-ci.bash
 - apt-get install -qq liblapack-dev </dev/null
```

Example package with testing
---
You can also test you packages using the ROS testing tools and GitLab CI pipelines, here is an example package:
- https://gitlab.com/VictorLamoine/ros_gitlab_ci_test
- https://gitlab.com/VictorLamoine/ros_gitlab_ci_test/blob/kinetic/.gitlab-ci.yml
