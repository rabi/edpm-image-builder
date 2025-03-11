#!/bin/bash

set -eux

pushd output
curl -sL https://github.com/openstack-k8s-operators/repo-setup/archive/refs/heads/main.tar.gz | tar xvz
pushd repo-setup-main
python3 -m venv ./venv
source ./venv/bin/activate
PBR_VERSION=0.0.0 python3 -m pip install ./
cp venv/bin/repo-setup ../repo-setup
popd
popd
