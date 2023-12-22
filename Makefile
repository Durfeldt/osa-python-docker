OSA_PLATFORM?=CentOS_7.8.2003_x86_64
#https://www.isdc.unige.ch/~savchenk/gitlab-ci/integral/build/osa-build-binary-tarball/CentOS_7.8.2003_x86_64/latest/build-latest/builder-info.yml
OSA_VERSION?=$(shell curl https://www.isdc.unige.ch/~savchenk/gitlab-ci/integral/build/osa-build-tarball/$(OSA_PLATFORM)/latest/latest/osa-version-ref.txt)
ISDC_REF_CAT_VERSION?=43.0
PYTHON_VERSION=3.10.11
HEASOFT_VERSION=6.32.1

OSA_IMAGE_TAG=${OSA_VERSION}-refcat-${ISDC_REF_CAT_VERSION}
IMAGE_TAG=${OSA_VERSION}-refcat-${ISDC_REF_CAT_VERSION}-heasoft-$(HEASOFT_VERSION)-python-$(PYTHON_VERSION)

IMAGE_BASE?=integralsw/osa-python

IMAGE?=$(IMAGE_BASE):$(IMAGE_TAG)
IMAGE_LATEST?=$(IMAGE_BASE):latest

push: build
	docker push $(IMAGE) 
	docker push $(IMAGE_LATEST) 

build: Dockerfile
	docker build --build-arg OSA_VERSION=$(OSA_VERSION) --build-arg python_version=$(PYTHON_VERSION) --build-arg heasoft_version=$(HEASOFT_VERSION) . -t $(IMAGE) 
	docker build --build-arg OSA_VERSION=$(OSA_VERSION) --build-arg python_version=$(PYTHON_VERSION) --build-arg heasoft_version=$(HEASOFT_VERSION) . -t $(IMAGE_LATEST)

squash:
	docker build --squash --build-arg OSA_VERSION=$(OSA_VERSION) --build-arg python_version=$(PYTHON_VERSION) --build-arg heasoft_version=$(HEASOFT_VERSION) . -t $(IMAGE)-squashed 
	docker build --squash --build-arg OSA_VERSION=$(OSA_VERSION) --build-arg python_version=$(PYTHON_VERSION) --build-arg heasoft_version=$(HEASOFT_VERSION) . -t $(IMAGE_LATEST)-squashed 
	

pull:
	docker pull $(IMAGE) 
	docker pull $(IMAGE_LATEST) 

#Dockerfile: Dockerfile.j2
#	j2 -e 'OSA_VERSION="$(OSA_IMAGE_TAG)"' Dockerfile.j2 -d -o Dockerfile

jupyter: build
	docker run --user $(id -u) $(IMAGE) bash -c 'export HOME_OVERRRIDE=/tmp; source /init.sh; jupyter notebook --ip 0.0.0.0 --no-browser'

test:
	docker run --user $(shell id -u) $(IMAGE) bash -c 'cd /tests; ls -ltor; make'
