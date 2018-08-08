[![ROS](http://www.ros.org/wp-content/uploads/2013/10/rosorg-logo1.png)](http://www.ros.org/)

[![build status](https://gitlab.com/VictorLamoine/ros_gitlab_ci/badges/master/build.svg)](https://gitlab.com/VictorLamoine/ros_gitlab_ci/commits/master)

Using Travis CI? Take a look at [ros-industrial/industrial_ci](https://github.com/ros-industrial/industrial_ci).

## Description
This repository contains helper scripts and instructions on how to use Continuous Integration (CI) for ROS projects hosted on a GitLab instance.

Supported ROS releases:
- Indigo
- Jade
- Kinetic
- Lunar
- Melodic

This repository uses the [ROS Docker](https://store.docker.com/images/ros) images to compile your packages, it does not run tests by default.

## How to use
Your repository must be hosted on a GitLab instance with CI working and Docker support.

Create a `.gitlab-ci.yml` that looks like this:

```yml
image: ros:melodic-ros-core

cache:
  paths:
    - ccache/

before_script:
  - git clone https://gitlab.com/VictorLamoine/ros_gitlab_ci.git
  - source ros_gitlab_ci/gitlab-ci.bash >/dev/null

catkin_make:
  stage: build
  script:
    - catkin_make

catkin tools:
  stage: build
  script:
    - catkin build --summarize --no-status --force-color
```
Commit, push to your repository and watch the pipeline! (make sure pipelines are enabled in your project settings).

If you want to test your packages after building them, read the [example package](#example-package-with-testing) section.

## Useful variables
- `ROS_PACKAGES_TO_INSTALL` (empty by default) specify extra ROS packages to install, for `ros-kinetic-rviz` just add `rviz` to the list, the ROS distro is automatically detected.
- `GLOBAL_C11` (not defined by default) forces C++11 for every project compiled, defined it to any value (eg `true`) to globally enable C++11.
- `DISABLE_GCC_COLORS` (false by default) disables gcc colour output ([-fdiagnostics-color](https://gcc.gnu.org/onlinedocs/gcc/Diagnostic-Message-Formatting-Options.html)).
- `DISABLE_CCACHE` (false by default) disables [ccache](https://ccache.samba.org/) gcc output caching.
- `USE_ROSDEP` (true by default) use [rosdep](http://wiki.ros.org/rosdep/) to install dependencies.

Example of using one of the available variables:
```yml
image: ros:melodic-ros-core

variables:
  ROS_PACKAGES_TO_INSTALL: "uuid-msgs"

before_script:
  - git clone https://gitlab.com/VictorLamoine/ros_gitlab_ci.git
  - source ros_gitlab_ci/gitlab-ci.bash >/dev/null

catkin_make:
  stage: build
  script:
    - catkin_make
```

## Installing extra APT packages
Just add them after sourcing `gitlab-ci.bash` in the `before_script` section, for example:

```yml
before_script:
 - git clone https://gitlab.com/VictorLamoine/ros_gitlab_ci.git
 - source ros_gitlab_ci/gitlab-ci.bash >/dev/null
 - apt install -y liblapack-dev >/dev/null
```

## Example package with testing
You can also test you packages using the ROS testing tools and GitLab CI pipelines, here is an example package:
- https://gitlab.com/VictorLamoine/ros_gitlab_ci_test
- https://gitlab.com/VictorLamoine/ros_gitlab_ci_test/blob/melodic/.gitlab-ci.yml
