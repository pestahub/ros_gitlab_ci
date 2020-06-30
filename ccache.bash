#!/bin/bash
apt-get install -qq ccache
export PATH="/usr/lib/ccache:$PATH"

# Setup path for ccache
export CCACHE_DIR=${CI_PROJECT_DIR}/ccache

# You need to add this to your GitLab CI config file:
#cache:
#  paths:
#    - ccache/
