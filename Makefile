#REGISTRYHOST=artifactory.dev.example.int:6555
REGISTRYHOST=127.0.0.1:5000
NAME = example/openldap
VERSION = 1.1.9

.PHONY: all build build-nocache test tag_latest release

all: build

build:
	docker build -t $(NAME):$(VERSION) --rm image

build-nocache:
	docker build -t $(NAME):$(VERSION) --no-cache --rm image

test:
	env NAME=$(NAME) VERSION=$(VERSION) bats test/test.bats

tag_latest:
	docker tag $(NAME):$(VERSION) $(REGISTRYHOST)/$(NAME):latest

release: build test tag_latest
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	docker push $(REGISTRYHOST)/$(NAME)
	@echo "*** Don't forget to run 'twgit release/hotfix finish' :)"
