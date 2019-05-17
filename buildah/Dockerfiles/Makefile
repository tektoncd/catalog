REGISTRY=quay.io/openshift-pipeline/buildah

all: build

build:
	docker build . -t $(REGISTRY) && docker push $(REGISTRY)
