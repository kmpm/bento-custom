
DEST_DIR           ?= ./target
PATHINSTBIN        = $(DEST_DIR)/bin
DOCKER_IMAGE       ?= ghcr.io/kmpm/bento-custom
GOEXE              = $(shell go env GOEXE)

# version stuff
VERSION     :=$(shell git describe --tags --always --dirty || echo "v0.0.0")
word-dot    =$(word $2,$(subst ., ,$1))
word-dash   =$(word $2,$(subst -, ,$1))
MAJOR       :=$(subst v,,$(call word-dot,$(VERSION),1))
MINOR       :=$(call word-dot,$(VERSION),2)
REVISION    :=$(call word-dash,$(call word-dot,$(VERSION),3),1)
PATCH       :=$(call word-dash,$(VERSION),2)

# all folders in cmd
APPS = $(filter %,$(shell cd cmd; find * -type d -exec basename {} \;))

LD_FLAGS   ?= -w -s
GO_FLAGS   ?=

.PHONY: all
all: $(APPS)
	@echo "APPS: $(APPS)"
	@echo "VERSION: $(VERSION)"
	@echo "MAJOR: $(MAJOR)"
	@echo "MINOR: $(MINOR)"
	@echo "REVISION: $(REVISION)"
	@echo "PATCH: $(PATCH)"


.PHONY: install
deps:
	@go mod tidy

SOURCE_FILES = $(shell find cmd -type f) go.mod go.sum

.PHONY: tidy
tidy:
	@go mod tidy -v
	go fmt ./... 

.PHONY: audit
audit:
	@echo "running checks"
	go mod verify
	go vet ./...
	go list -m all
	go run honnef.co/go/tools/cmd/staticcheck@latest -checks=all,-ST1000,-U1000 ./...
	go run golang.org/x/vuln/cmd/govulncheck@latest ./...

.PHONY: no-dirty
no-dirty:
	git diff --exit-code

$(APPS): %: $(PATHINSTBIN)/%$(GOEXE)
	

$(PATHINSTBIN)/%: 
	go build $(GO_FLAGS) -tags "$(TAGS)" -ldflags "$(LD_FLAGS) $(VER_FLAGS)" -o $@ ./cmd/$(subst $(GOEXE),,$*)


docker:
	@echo "Building docker image $(DOCKER_IMAGE):$(VERSION)"
	@docker build -f ./resources/docker/Dockerfile . -t $(DOCKER_IMAGE):$(VERSION)
	@echo "Tagging docker image $(DOCKER_IMAGE):latest"
	@docker tag $(DOCKER_IMAGE):$(VERSION) $(DOCKER_IMAGE):latest