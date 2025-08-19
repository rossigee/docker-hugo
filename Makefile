# Registry configuration
HARBOR_REPO=harbor.golder.lan/library/hugo
DOCKERHUB_REPO=rossigee/hugo
VERSION?=$(shell grep "ENV HUGO_VERSION" Dockerfile | cut -d= -f2)
GIT_SHA?=$(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILD_VERSION=$(VERSION)-$(GIT_SHA)

.PHONY: build test scan push push-harbor push-dockerhub all clean

all: build test scan push

build:
	@echo "Building Hugo image with version: $(VERSION)"
	docker build \
		--build-arg BUILD_DATE=$$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
		--build-arg VCS_REF=$(GIT_SHA) \
		-t $(HARBOR_REPO):$(VERSION) \
		-t $(HARBOR_REPO):$(BUILD_VERSION) \
		-t $(HARBOR_REPO):latest \
		-t $(DOCKERHUB_REPO):$(VERSION) \
		-t $(DOCKERHUB_REPO):$(BUILD_VERSION) \
		-t $(DOCKERHUB_REPO):latest .

test:
	@echo "Running container tests..."
	docker run --rm $(HARBOR_REPO):$(VERSION) hugo version
	@echo "Testing Hugo server functionality..."
	docker run -d --name hugo-test -p 1313:1313 $(HARBOR_REPO):$(VERSION) hugo server --bind 0.0.0.0 --appendPort=false --baseURL=http://localhost:1313
	sleep 3
	docker exec hugo-test pkill hugo || true
	docker stop hugo-test && docker rm hugo-test

scan:
	@echo "Scanning image for vulnerabilities..."
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
		aquasec/trivy:latest image --severity HIGH,CRITICAL \
		$(DOCKERHUB_REPO):$(VERSION)

push-harbor:
	@echo "Pushing to Harbor registry..."
	docker push $(HARBOR_REPO):$(VERSION)
	docker push $(HARBOR_REPO):$(BUILD_VERSION)
	docker push $(HARBOR_REPO):latest

push-dockerhub:
	@echo "Pushing to Docker Hub..."
	docker push $(DOCKERHUB_REPO):$(VERSION)
	docker push $(DOCKERHUB_REPO):$(BUILD_VERSION)
	docker push $(DOCKERHUB_REPO):latest

push: push-harbor push-dockerhub

clean:
	docker rmi $(HARBOR_REPO):$(VERSION) $(HARBOR_REPO):$(BUILD_VERSION) $(HARBOR_REPO):latest || true
	docker rmi $(DOCKERHUB_REPO):$(VERSION) $(DOCKERHUB_REPO):$(BUILD_VERSION) $(DOCKERHUB_REPO):latest || true