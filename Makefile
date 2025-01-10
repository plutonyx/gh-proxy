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
package: 
	@echo "Building image $(REPOSITORY)/$(IMAGE_NAME):$(GIT_SHA_FETCH)"
	@echo "Using Dockerfile: $(DOCKERFILE)"
	docker build -t $(REPOSITORY)/$(IMAGE_NAME):$(GIT_SHA_FETCH) -f $(DOCKERFILE) .

.PHONY: publish
publish: package
	@echo "Pushing image $(REPOSITORY)/$(IMAGE_NAME):$(GIT_SHA_FETCH)"
	docker push $(REPOSITORY)/$(IMAGE_NAME):$(GIT_SHA_FETCH)

.PHONY: test
test:
	@go test -v ./...


# --- release --- 
.PHONY: clean release
clean:
	rm -rf bin/*
release: clean
	GOOS=darwin     GOARCH=amd64    go build -ldflags '-s' -o bin/${APP_NAME}-darwin-amd64       .
	GOOS=darwin     GOARCH=arm64    go build -ldflags '-s' -o bin/${APP_NAME}-darwin-arm64       .
	GOOS=linux      GOARCH=386      go build -ldflags '-s' -o bin/${APP_NAME}-linux-386          .
	GOOS=linux      GOARCH=amd64    go build -ldflags '-s' -o bin/${APP_NAME}-linux-amd64        .
	GOOS=linux      GOARCH=arm      go build -ldflags '-s' -o bin/${APP_NAME}-linux-arm          .
	GOOS=linux      GOARCH=arm64    go build -ldflags '-s' -o bin/${APP_NAME}-linux-arm64        .
	GOOS=windows    GOARCH=386      go build -ldflags '-s' -o bin/${APP_NAME}-windows-386.exe    .
	GOOS=windows    GOARCH=amd64    go build -ldflags '-s' -o bin/${APP_NAME}-windows-amd64.exe  .
