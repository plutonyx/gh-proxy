REPOSITORY=plutonyx
GIT_SHA_FETCH := $(shell git rev-parse HEAD | cut -c 1-8)
IMAGE_NAME := gh-proxy
DOCKERFILE := ./Dockerfile

.PHONY: all
all: publish

.PHONY: clean
clean:
	@rm -rf ./bin

.PHONY: build
build: clean 
	@go build -a -installsuffix cgo -o ./bin/app .

.PHONY: package
package: build
	@echo "Building image $(REPOSITORY)/$(IMAGE_NAME):$(GIT_SHA_FETCH)"
	@echo "Using Dockerfile: $(DOCKERFILE)"
	docker build -t $(REPOSITORY)/$(IMAGE_NAME):$(GIT_SHA_FETCH) -f $(DOCKERFILE) .

.PHONY: publish
publish: package
	@echo "Pushing image $(REPOSITORY)/$(IMAGE_NAME):$(GIT_SHA_FETCH)"
	docker push $(REPOSITORY)/$(IMAGE_NAME):$(GIT_SHA_FETCH)
