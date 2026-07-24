========================
EDPM bootc image builder
========================

Pre-requesites can be installed by running::

    make host-deps

The bootc build defaults target CentOS Stream 9. To build a CentOS Stream 10
based bootc EDPM container image, override the base image and repo-setup distro
then run the following commands::

    export EDPM_BOOTC_REPO=quay.io/<account>/edpm-bootc
    export EDPM_BOOTC_TAG=centos10
    export EDPM_BASE_IMAGE=quay.io/centos-bootc/centos-bootc:stream10
    export REPO_SETUP_DISTRO=centos10
    export REPO_SETUP_BRANCH=master
    export REPO_SETUP=current
    make build
    sudo podman push $EDPM_BOOTC_REPO:$EDPM_BOOTC_TAG

.. note::

   ``current-podified`` is not yet available for CentOS Stream 10. The above
   uses ``current`` and ``master`` branch until promotion to
   ``current-podified`` includes the required fixes.

To continue using CentOS Stream 9, leave the defaults in place and run
``make build`` (the default tag is ``latest``).

To build a RHEL 9 based bootc EDPM container image using internal repositories,
install the required certificates then run the following commands::

    # switch to RHEL 9 images
    export BUILDER_IMAGE=registry.redhat.io/rhel9/bootc-image-builder:latest
    export EDPM_BASE_IMAGE=registry.redhat.io/rhel9/rhel-bootc:latest

    # Config to build repository files for internal repos
    export CURL_CA_BUNDLE=/etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt
    export REPO_SETUP_DISTRO=rhel9
    export REPO_SETUP=current-podified
    export REPO_SETUP_BRANCH=osp18
    export REPO_SETUP_MIRROR=<mirror for internal repos>
    export REPO_SETUP_EXTRA="rhos-release ceph-6.0 -r 9.4 -t yum.repos.d"

    # login to the registry
    sudo podman login registry.redhat.io

    export EDPM_BOOTC_REPO=quay.io/<account>/edpm-bootc
    export EDPM_BOOTC_TAG=rhel9-rhos-release
    make build
    sudo podman push $EDPM_BOOTC_REPO:$EDPM_BOOTC_TAG

To build a RHEL 10 based bootc EDPM container image using internal
repositories, use the matching RHEL 10 images and repo-setup distro::

    # switch to RHEL 10 images
    export BUILDER_IMAGE=registry.redhat.io/rhel10/bootc-image-builder:latest
    export EDPM_BASE_IMAGE=registry.redhat.io/rhel10/rhel-bootc:latest

    # Config to build repository files for internal repos
    export CURL_CA_BUNDLE=/etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt
    export REPO_SETUP_DISTRO=rhel10
    export REPO_SETUP=current-podified
    export REPO_SETUP_BRANCH=osp18
    export REPO_SETUP_MIRROR=<mirror for internal repos>
    export REPO_SETUP_EXTRA="rhos-release ceph-6.0 -r 10 -t yum.repos.d"

    # login to the registry
    sudo podman login registry.redhat.io

    export EDPM_BOOTC_REPO=quay.io/<account>/edpm-bootc
    export EDPM_BOOTC_TAG=rhel10-rhos-release
    make build
    sudo podman push $EDPM_BOOTC_REPO:$EDPM_BOOTC_TAG

To build a RHEL 9 or RHEL 10 based bootc EDPM container using published
packages, run the following commands::

    # switch to the matching RHEL bootc images
    export BUILDER_IMAGE=registry.redhat.io/rhel9/bootc-image-builder:latest
    export EDPM_BASE_IMAGE=registry.redhat.io/rhel9/rhel-bootc:latest
    export RHEL_MAJOR=9

    # make a custom copy of the subscription-manager script and edit it for
    # your registration details. The script is mounted as a build secret and
    # will not be committed to any image layer.
    cp rhsm.sh rhsm-custom.sh
    # edit RHSM_USER and RHSM_PASSWORD in rhsm-custom.sh
    export RHSM_SCRIPT=rhsm-custom.sh

    export EDPM_BOOTC_REPO=quay.io/<account>/edpm-bootc
    export EDPM_BOOTC_TAG=rhel9-rhsm
    make build
    sudo podman push $EDPM_BOOTC_REPO:$EDPM_BOOTC_TAG

Set ``RHEL_MAJOR=10`` and switch the ``BUILDER_IMAGE``, ``EDPM_BASE_IMAGE``,
and ``EDPM_BOOTC_TAG`` values to their ``rhel10`` equivalents to build the
same image against RHEL 10.

To convert this container image to ``output/edpm-bootc.qcow2``, run the
following command::

    make edpm-bootc.qcow2

To package ``edpm-bootc.qcow2`` inside a container image EDPM baremetal
deployment, run the following command::

    make package
    sudo podman push $EDPM_BOOTC_REPO:$EDPM_BOOTC_TAG-qcow2

To deploy EDPM baremetal with this image, customize the
``baremetalSetTemplate`` substituting values for ``<EDPM_BOOTC_REPO>`` and
``<EDPM_BOOTC_TAG>`` ::

    kind: OpenStackDataPlaneNodeSet
    spec:
    baremetalSetTemplate:
        osContainerImageUrl: <EDPM_BOOTC_REPO>:<EDPM_BOOTC_TAG>-qcow2
        osImage: edpm-bootc.qcow2
