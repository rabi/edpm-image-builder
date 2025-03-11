========================
EDPM bootc image builder
========================

Pre-requesites can be installed by running::

    make host-deps

To build a CentOS-9-Stream based bootc EDPM container image, run the following
commands::

    export EDPM_BOOTC_REPO=quay.io/<account>/edpm-bootc
    export EDPM_BOOTC_TAG=centos9
    make build
    sudo podman push $EDPM_BOOTC_REPO:$EDPM_BOOTC_TAG

To build a RHEL-9.4 based bootc EDPM container image using internal
repositories, install the required certificates then run the following
commands::

    # switch to RHEL-9.4 images
    export BUILDER_IMAGE=registry.redhat.io/rhel9/bootc-image-builder:9.4
    export EDPM_BASE_IMAGE=registry.redhat.io/rhel9/rhel-bootc:9.4

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
    export EDPM_BOOTC_TAG=rhel9
    make build
    sudo podman push $EDPM_BOOTC_REPO:$EDPM_BOOTC_TAG

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
