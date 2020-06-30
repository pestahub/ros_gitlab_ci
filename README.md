[![ROS](http://www.ros.org/wp-content/uploads/2013/10/rosorg-logo1.png)](http://www.ros.org/)

Using Travis CI? Take a look at [ros-industrial/industrial_ci](https://github.com/ros-industrial/industrial_ci).

## Description
This repository contains helper scripts and instructions on how to use Continuous Integration (CI) for ROS projects hosted on a GitLab instance.

Supported ROS releases (older release should be supported too):
- `melodic`
- `noetic`

This repository uses the [ROS Docker](https://store.docker.com/images/ros) images to compile your packages, it does not run tests by default.

## How to use
Your repository must be hosted on a GitLab instance with CI working and Docker support.

Create a `.gitlab-ci.yml` that looks like this:

```yml
image: ros:noetic-ros-core

cache:
  paths:
    - ccache/

before_script:
  - apt update >/dev/null && apt install -y git >/dev/null
  - git clone https://gitlab.com/VictorLamoine/ros_gitlab_ci.git >/dev/null
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
- `DISABLE_CCACHE` (false by default), if defined to `true`: disables [ccache](https://ccache.samba.org/) gcc output caching.
- `USE_ROSDEP` (true by default) use [rosdep](http://wiki.ros.org/rosdep/) to install dependencies. Define to `false` to disable.
- `ROSINSTALL_CI_JOB_TOKEN` (false by default), if defined to `true`: makes it possible to clone private repositories using wstool by using the [CI job permissions mode](https://docs.gitlab.com/ee/user/project/new_ci_build_permissions_model.html). Requires GitLab 8.12 minimum and that the private repositories are on the same GitLab server.
- `WSTOOL_RECURSIVE` (false by default), if defined to `true`: wstool will be used to cloned recursively every repositories specified in the `*.rosinstall` files. For this feature to work:
  - The rosinstall file names must be unique
  - No repository may contain a space in it's name

## Installing extra APT packages
Just add them after sourcing `gitlab-ci.bash` in the `before_script` section, for example:

```yml
before_script:
 - apt update >/dev/null && apt install -y git >/dev/null
 - git clone https://gitlab.com/VictorLamoine/ros_gitlab_ci.git >/dev/null
 - source ros_gitlab_ci/gitlab-ci.bash >/dev/null
 - apt install -y liblapack-dev ros-noetic-uuid-msgs >/dev/null
```

## Using with [`catkin_lint`](http://wiki.ros.org/catkin_lint)
Example usage:
```yml
catkin lint:
  stage: test
  image: ros:noetic-ros-core
  needs: []
before_script:
    - apt update >/dev/null && apt install -y python3-catkin-lint >/dev/null
  script:
    - catkin_lint -W2 .
```

## Example package with testing
You can also test you packages using the ROS testing tools and GitLab CI pipelines.

Example package: https://gitlab.com/VictorLamoine/ros_gitlab_ci_test
