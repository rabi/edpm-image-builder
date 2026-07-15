#!/bin/bash

set -eu

# Edit RHSM_ values for the subscription configuration
RHSM_USER=unset
RHSM_PASSWORD=unset
RHEL_MAJOR=${RHEL_MAJOR:-9}
RHSM_REPOS=${RHSM_REPOS:-"--enable=rhoso-18.0-for-rhel-${RHEL_MAJOR}-x86_64-rpms \
            --enable=rhceph-8-tools-for-rhel-${RHEL_MAJOR}-x86_64-rpms \
            --enable=fast-datapath-for-rhel-${RHEL_MAJOR}-x86_64-rpms"}
# Only required when Simple Content Access (SCA) is disabled
RHSM_POOL=""

rm -f /etc/yum.repos.d/*.repo
# Disable subscription-manager container detection so that registration
# works during container builds. subscription-manager checks for
# /etc/rhsm-host (a symlink to ../run/secrets/rhsm) to detect
# container mode.
if [ -L /etc/rhsm-host ]; then
    rm -f /etc/rhsm-host
fi

# Suppress xtrace to avoid leaking credentials to the build log
set +x
subscription-manager register --username="$RHSM_USER" --password="$RHSM_PASSWORD"
set -x
if [ -n "${RHSM_POOL}" ]; then
    subscription-manager attach --pool="$RHSM_POOL"
fi
subscription-manager repos $RHSM_REPOS
