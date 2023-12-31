#!/bin/bash
apt install -qq -y gettext >/dev/null
# Replace SSH URL by https URL first
sed -i 's/git\@gitlab\.com:/https:\/\/gitlab\.com\//g' $1
# Then replace https URL to using CI_JOB_TOKEN
sed -i 's/https:\/\/gitlab\./https:\/\/gitlab-ci-token:\$\{CI_JOB_TOKEN\}\@gitlab\./g' $1
# Replace CI_JOB_TOKEN by its content
envsubst < $1 > tmp.rosinstall
rm $1
mv tmp.rosinstall $1
