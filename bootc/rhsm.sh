#!/bin/bash

set -eux

# Edit RHSM_ values for the subscription configuration
RHSM_USER=unset
RHSM_PASSWORD=unset
RHSM_REPOS="--enable=rhoso-18.0-for-rhel-9-x86_64-rpms \
            --enable=rhceph-8-tools-for-rhel-9-x86_64-rpms \
            --enable=fast-datapath-for-rhel-9-x86_64-rpms"
# Only required when Simple Content Access (SCA) is disabled
RHSM_POOL=""

rm /etc/yum.repos.d/*.repo
subscription-manager register --username=$RHSM_USER --password=$RHSM_PASSWORD
if [ -n "${RHSM_POOL}" ]; then
    subscription-manager attach --pool=$RHSM_POOL
fi
subscription-manager repos $RHSM_REPOS
