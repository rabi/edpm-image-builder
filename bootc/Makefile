SHELL := /bin/bash
EDPM_BOOTC_REPO ?= quay.io/openstack-k8s-operators/edpm-bootc
EDPM_BOOTC_TAG ?= latest
EDPM_CONTAINERFILE ?= Containerfile
EDPM_BASE_IMAGE ?= quay.io/centos-bootc/centos-bootc:stream9
EDPM_BOOTC_IMAGE ?= ${EDPM_BOOTC_REPO}:${EDPM_BOOTC_TAG}
EDPM_QCOW2_IMAGE ?= ${EDPM_BOOTC_REPO}:${EDPM_BOOTC_TAG}-qcow2
BUILDER_IMAGE ?= quay.io/centos-bootc/bootc-image-builder:latest
HOST_PACKAGES ?= podman osbuild-selinux https://download.devel.redhat.com/rcm-guest/puddles/OpenStack/rhos-release/rhos-release-latest.noarch.rpm
RHSM_SCRIPT ?= empty.sh

.ONESHELL:

.PHONY: host-deps
host-deps:
	sudo dnf install -y ${HOST_PACKAGES}

output:
	mkdir -p output

output/repo-setup: output
	ls output/repo-setup && exit 0 || true
	./install-repo-setup.sh

output/yum.repos.d: output/repo-setup
	ls output/yum.repos.d && exit 0 || true
	mkdir -p output/yum.repos.d
	./run-repo-setup.sh

.PHONY: build
build: output/yum.repos.d
	sudo buildah inspect ${EDPM_BOOTC_IMAGE} > /dev/null && exit 0 || true
	sudo buildah bud \
		--build-arg EDPM_BASE_IMAGE=${EDPM_BASE_IMAGE} \
		--build-arg RHSM_SCRIPT=${RHSM_SCRIPT} \
		--volume /etc/pki/ca-trust:/etc/pki/ca-trust:ro,Z \
		--volume $(shell pwd)/output/yum.repos.d:/etc/yum.repos.d:rw,Z \
		-f ${EDPM_CONTAINERFILE} \
		-t ${EDPM_BOOTC_IMAGE} .

.PHONY: build-push
build-push: build
	sudo podman push ${EDPM_BOOTC_IMAGE}

.PHONY: edpm-bootc.qcow2
edpm-bootc.qcow2: build edpm-bootc.qcow2-no-build

.PHONY: edpm-bootc.qcow2-no-build
edpm-bootc.qcow2-no-build:
	ls output/edpm-bootc.qcow2 && exit 0 || true
	sudo podman run --rm -it --privileged \
		--security-opt label=type:unconfined_t \
		-v ./output:/output \
		-v /var/lib/containers/storage:/var/lib/containers/storage \
		${BUILDER_IMAGE} \
		--type qcow2 \
		--local \
		${EDPM_BOOTC_IMAGE}
	cd output
	sudo mv qcow2/disk.qcow2 edpm-bootc.qcow2
	sudo sha256sum edpm-bootc.qcow2 > edpm-bootc.qcow2.sha256

.PHONY: package
package: edpm-bootc.qcow2 package-no-qcow2

.PHONY: package-cp-deps
package-cp-deps:
	cp ../copy_out.sh output/
	cp ../Containerfile.image output/

.PHONY: package-no-qcow2
package-no-qcow2: package-cp-deps
	sudo buildah inspect ${EDPM_QCOW2_IMAGE} > /dev/null && exit 0 || true
	cd output
	sudo buildah bud --build-arg IMAGE_NAME=edpm-bootc -f ./Containerfile.image -t ${EDPM_QCOW2_IMAGE}

.PHONY: package-push
package-push: package
	sudo podman push ${EDPM_QCOW2_IMAGE}

.PHONY: all
all: build edpm-bootc.qcow2 package

.PHONY: clean
clean:
	sudo rm -rf output

.PHONY: realclean
realclean: clean
	sudo podman rmi --force ${EDPM_BOOTC_IMAGE} || true
	sudo podman rmi --force ${BUILDER_IMAGE} || true
	sudo podman rmi --force ${EDPM_QCOW2_IMAGE} || true
