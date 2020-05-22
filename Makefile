SHELL = /bin/sh
IMAGE_PREFIX 					?= any-cloud-accelerators
REPO_IMAGES 					:= $(shell docker images -q '$(PREFIX)*' | uniq)
BASE_IMAGE 						= $(IMAGE_PREFIX)-base
BASE_VERSION 					?= 18.04
BASE_IMAGE_TAG				= $(BASE_IMAGE):$(BASE_VERSION)
VAULT_IMAGE 					= $(IMAGE_PREFIX)-vault
VAULT_VERSION 				?= 1.4.1
VAULT_IMAGE_TAG				= $(VAULT_IMAGE):$(VAULT_VERSION)
VAULT_MODE						?= dev ## Supports 'dev' or 'ui' ('ui' significantly increases build time)
TERRAFORM_IMAGE 			= $(IMAGE_PREFIX)-terraform
TERRAFORM_VERSION 		?= 0.12.25
TERRAFORM_IMAGE_TAG		= $(TERRAFORM_IMAGE):$(TERRAFORM_VERSION)
PACKER_IMAGE 					= $(IMAGE_PREFIX)-packer
PACKER_VERSION 				?= 1.5.6
PACKER_IMAGE_TAG			= $(PACKER_IMAGE):$(PACKER_VERSION)
GO_IMAGE							= $(IMAGE_PREFIX)-go
GO_VERSION						?= 1.14.3
GO_IMAGE_TAG					= $(GO_IMAGE):$(GO_VERSION)
NODE_IMAGE						= $(IMAGE_PREFIX)-node
NODE_VERSION					?= 10.20.1
NODE_IMAGE_TAG				= $(NODE_IMAGE):$(NODE_VERSION)
PYTHON_IMAGE					= $(IMAGE_PREFIX)-python
PYTHON_VERSION				?= 3.8.3
PYTHON_IMAGE_TAG			= $(PYTHON_IMAGE):$(PYTHON_VERSION)
OPENSSL_IMAGE					= $(IMAGE_PREFIX)-openssl
OPENSSL_VERSION				?= 1.1.1g
OPENSSL_IMAGE_TAG			= $(OPENSSL_IMAGE):$(OPENSSL_VERSION)
IBM_CLI_IMAGE					= $(IMAGE_PREFIX)-ibm-cli
IBM_CLI_VERSION				?= 1.1.0
IBM_CLI_IMAGE_TAG			= $(IBM_CLI_IMAGE):$(IBM_CLI_VERSION)
IBM_TF_IMAGE					= $(IMAGE_PREFIX)-ibm-tf
IBM_TF_VERSION				?= 0.28.0
IBM_TF_IMAGE_TAG			= $(IBM_TF_IMAGE):$(IBM_TF_VERSION)

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

base: docker ## Builds base container
				docker build --rm ./common/base --build-arg VERSION=$(BASE_VERSION) -t $(BASE_IMAGE_TAG)

openssl: base ## Builds an openssl container
				docker build --rm ./common/openssl --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg VERSION=$(OPENSSL_VERSION) -t $(OPENSSL_IMAGE_TAG)

go: base ## Builds a go build container
				docker build --rm ./common/go --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg VERSION=$(GO_VERSION) -t $(GO_IMAGE_TAG)

node: base ## Builds a nodejs build container
				docker build --rm ./common/node --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg VERSION=$(NODE_VERSION) -t $(NODE_IMAGE_TAG)

python: base openssl ## Builds a python build container
				docker build --rm ./common/python --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg OPENSSLIMAGE=$(OPENSSL_IMAGE_TAG) --build-arg VERSION=$(PYTHON_VERSION) -t $(PYTHON_IMAGE_TAG)

vault: base go node ## Builds vault container
				docker build --rm ./common/vault --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg GOIMAGE=$(GO_IMAGE_TAG) --build-arg NODEIMAGE=$(NODE_IMAGE_TAG) --build-arg VERSION=$(VAULT_VERSION) --build-arg MODE=$(VAULT_MODE) -t $(VAULT_IMAGE_TAG)

terraform: base go ## Builds terraform container
				docker build --rm ./common/terraform --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg GOIMAGE=$(GO_IMAGE_TAG) --build-arg VERSION=$(TERRAFORM_VERSION) -t $(TERRAFORM_IMAGE_TAG)

packer: base go ## Builds packer container
				docker build --rm ./common/packer --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg GOIMAGE=$(GO_IMAGE_TAG) --build-arg VERSION=$(PACKER_VERSION) -t $(PACKER_IMAGE_TAG)

docker: ## Prints docker version
				docker version -f "{{.Client.Platform.Name}} v{{.Client.Version}}"

common: terraform vault ## Builds all common images in toolchain

ibm-tf: terraform go ## Builds a terraform container with the IBM provider plugin
				docker build --rm ./IBM/terraform --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg VERSION=$(IBM_TF_VERSION) --build-arg TFIMAGE=$(TERRAFORM_IMAGE_TAG) --build-arg GOIMAGE=$(GO_IMAGE_TAG) -t $(IBM_TF_IMAGE_TAG)

ibm-cli: base openssl ## Builds the IBM Cloud CLI with plugins in a container
				docker build --rm ./IBM/cli --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg OPENSSLIMAGE=$(OPENSSL_IMAGE_TAG) --build-arg VERSION=$(IBM_CLI_VERSION) -t $(IBM_CLI_IMAGE_TAG)

ibm: ibm-tf ibm-cli ## Builds all IBM Cloud accelerators in containers

clouds: ibm ## Builds all cloud accelerators in containers

clean: ## Removes all container images associated with this repo
				docker rmi -f $(REPO_IMAGES)
