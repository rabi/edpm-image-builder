#!/bin/bash

set -eux

REPO_SETUP=${REPO_SETUP:-current-podified}
REPO_SETUP_BRANCH=${REPO_SETUP_BRANCH:-antelope}
REPO_SETUP_DISTRO=${REPO_SETUP_DISTRO:-centos9}
REPO_SETUP_MIRROR=${REPO_SETUP_MIRROR:-https://trunk.rdoproject.org}
REPO_SETUP_EXTRA=${REPO_SETUP_EXTRA:-echo Done}

pushd output
./repo-setup --output-path yum.repos.d --branch ${REPO_SETUP_BRANCH} --rdo-mirror ${REPO_SETUP_MIRROR} -d ${REPO_SETUP_DISTRO} ${REPO_SETUP}
$REPO_SETUP_EXTRA
popd
