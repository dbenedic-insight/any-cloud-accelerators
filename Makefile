SHELL                  = /bin/sh
IMAGE_PREFIX          ?= aca
REPO_IMAGES           := $(shell docker images -q '$(PREFIX)*' | uniq)
DANGLING_IMAGES       := $(shell docker images --filter "dangling=true" -q)
BASE_IMAGE             = $(IMAGE_PREFIX)-base
BASE_VERSION          ?= 18.04
BASE_IMAGE_TAG         = $(BASE_IMAGE):$(BASE_VERSION)
VAULT_IMAGE            = $(IMAGE_PREFIX)-vault
VAULT_VERSION         ?= 1.4.1
VAULT_IMAGE_TAG        = $(VAULT_IMAGE):$(VAULT_VERSION)
VAULT_MODE            ?= dev ## Supports 'dev' or 'ui' ('ui' significantly increases build time)
TERRAFORM_IMAGE        = $(IMAGE_PREFIX)-terraform
TERRAFORM_VERSION     ?= 0.12.29
TERRAFORM_IMAGE_TAG    = $(TERRAFORM_IMAGE):$(TERRAFORM_VERSION)
PACKER_IMAGE           = $(IMAGE_PREFIX)-packer
PACKER_VERSION        ?= 1.5.6
PACKER_IMAGE_TAG       = $(PACKER_IMAGE):$(PACKER_VERSION)
GO_IMAGE               = $(IMAGE_PREFIX)-go
GO_VERSION            ?= 1.15
GO_IMAGE_TAG           = $(GO_IMAGE):$(GO_VERSION)
TERRAFORMER_IMAGE      = $(IMAGE_PREFIX)-terraformer
TERRAFORMER_VERSION   ?= 0.8.8
TERRAFORMER_IMAGE_TAG  = $(TERRAFORMER_IMAGE):$(TERRAFORMER_VERSION)
NODE_IMAGE             = $(IMAGE_PREFIX)-node
NODE_VERSION          ?= 10.20.1
NODE_IMAGE_TAG         = $(NODE_IMAGE):$(NODE_VERSION)
PYTHON_IMAGE           = $(IMAGE_PREFIX)-python
PYTHON_VERSION        ?= 3.9.0
PYTHON_IMAGE_TAG       = $(PYTHON_IMAGE):$(PYTHON_VERSION)
OPENSSL_IMAGE          = $(IMAGE_PREFIX)-openssl
OPENSSL_VERSION       ?= 1.1.1h
OPENSSL_IMAGE_TAG      = $(OPENSSL_IMAGE):$(OPENSSL_VERSION)
IBM_CLI_IMAGE          = $(IMAGE_PREFIX)-ibm-cli
IBM_CLI_VERSION       ?= 1.1.0
IBM_CLI_IMAGE_TAG      = $(IBM_CLI_IMAGE):$(IBM_CLI_VERSION)
IBM_TF_IMAGE           = $(IMAGE_PREFIX)-ibm-tf
IBM_TF_VERSION        ?= 0.28.0
IBM_TF_IMAGE_TAG       = $(IBM_TF_IMAGE):$(IBM_TF_VERSION)
AZURE_CLI_IMAGE        = $(IMAGE_PREFIX)-az-cli
AZURE_CLI_VERSION     ?= 2.6.0
AZURE_CLI_IMAGE_TAG    = $(AZURE_CLI_IMAGE):$(AZURE_CLI_VERSION)
AZURE_TF_IMAGE         = $(IMAGE_PREFIX)-az-tf
AZURE_TF_VERSION      ?= 0.28.0
AZURE_TF_IMAGE_TAG     = $(AZURE_TF_IMAGE):$(AZURE_TF_VERSION)
GCP_BASE_IMAGE         = ${IMAGE_PREFIX}-gcp-base
GCP_BASE_VERSION       = 1.0.0
GCP_BASE_IMAGE_TAG     = ${GCP_BASE_IMAGE}:${GCP_BASE_VERSION}
GCP_CLI_IMAGE          = $(IMAGE_PREFIX)-gcp-sdk
GCP_CLI_VERSION       ?= 304.0.0
GCP_CLI_IMAGE_TAG      = $(GCP_CLI_IMAGE):$(GCP_CLI_VERSION)
AWS_CLI_IMAGE          = $(IMAGE_PREFIX)-aws-cli
AWS_CLI_VERSION       ?= 1.18.73
AWS_CLI_IMAGE_TAG      = $(AWS_CLI_IMAGE):$(AWS_CLI_VERSION)
ANSIBLE_IMAGE          = $(IMAGE_PREFIX)-ansible
ANSIBLE_VERSION       ?= 2.9.12
ANSIBLE_IMAGE_TAG      = $(ANSIBLE_IMAGE):$(ANSIBLE_VERSION)

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

go: base openssl ## Builds a go build container
	docker build --rm ./common/go --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg OPENSSLIMAGE=$(OPENSSL_IMAGE_TAG) --build-arg VERSION=$(GO_VERSION) -t $(GO_IMAGE_TAG)

node: base ## Builds a nodejs build container
	docker build --rm ./common/node --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg VERSION=$(NODE_VERSION) -t $(NODE_IMAGE_TAG)

python: base openssl ## Builds a python build container
	docker build --rm ./common/python --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg OPENSSLIMAGE=$(OPENSSL_IMAGE_TAG) --build-arg VERSION=$(PYTHON_VERSION) -t $(PYTHON_IMAGE_TAG)

vault: base go node ## Builds vault container
	docker build --rm ./common/vault --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg GOIMAGE=$(GO_IMAGE_TAG) --build-arg NODEIMAGE=$(NODE_IMAGE_TAG) --build-arg VERSION=$(VAULT_VERSION) --build-arg MODE=$(VAULT_MODE) -t $(VAULT_IMAGE_TAG)

terraform: base go openssl ## Builds terraform container
	docker build --rm ./common/terraform --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg GOIMAGE=$(GO_IMAGE_TAG) --build-arg OPENSSLIMAGE=$(OPENSSL_IMAGE_TAG) --build-arg VERSION=$(TERRAFORM_VERSION) -t $(TERRAFORM_IMAGE_TAG)

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

az-cli: base openssl python ## Builds an azcli container
	docker build --rm ./azure/cli --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg OPENSSLIMAGE=$(OPENSSL_IMAGE_TAG) --build-arg PYTHONIMAGE=$(PYTHON_IMAGE_TAG) --build-arg VERSION=$(AZURE_CLI_VERSION) -t $(AZURE_CLI_IMAGE_TAG)

azure: base az-cli ## Builds all Azure cloud accelerators in containers

gcp-base: base ## Builds a common intermediate base container for GCP
	docker build --rm ./gcp/base --build-arg BASEIMAGE=${BASE_IMAGE_TAG} --build-arg VERSION=$(GCP_BASE_VERSION) -t $(GCP_BASE_IMAGE_TAG)

gcp-sdk: gcp-base python openssl ## Builds the Google Cloud Platform (GCP) SDK in a container
	docker build --rm ./gcp/sdk --build-arg BASEIMAGE=$(GCP_BASE_IMAGE_TAG) --build-arg OPENSSLIMAGE=$(OPENSSL_IMAGE_TAG) --build-arg PYTHONIMAGE=$(PYTHON_IMAGE_TAG) --build-arg VERSION=$(GCP_CLI_VERSION) -t $(GCP_CLI_IMAGE_TAG)

gcp: base gcp-sdk

aws-cli: base openssl python ## Builds an azcli container
	docker build --rm ./aws/cli --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg OPENSSLIMAGE=$(OPENSSL_IMAGE_TAG) --build-arg PYTHONIMAGE=$(PYTHON_IMAGE_TAG) --build-arg VERSION=$(AWS_CLI_VERSION) -t $(AWS_CLI_IMAGE_TAG)

aws: aws-cli

clouds: aws azure gcp ibm ## Builds all cloud accelerators in containers

terraformer: base go openssl python gcp terraform ## Builds terraformer container
	docker build --rm ./common/terraformer --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg GOIMAGE=$(GO_IMAGE_TAG) --build-arg OPENSSLIMAGE=$(OPENSSL_IMAGE_TAG) --build-arg TERRAFORMIMAGE=$(TERRAFORM_IMAGE_TAG) --build-arg GCPCLIIMAGE=$(GCP_CLI_IMAGE_TAG) --build-arg PYTHONIMAGE=$(PYTHON_IMAGE_TAG) --build-arg VERSION=$(TERRAFORMER_VERSION) -t $(TERRAFORMER_IMAGE_TAG)

ansible: base python
	docker build --rm ./common/ansible --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg PYTHONIMAGE=$(PYTHON_IMAGE_TAG) --build-arg VERSION=$(ANSIBLE_VERSION) -t $(ANSIBLE_IMAGE_TAG)

tidy: ## Removes intermediate build containers (aka "dangling")
	docker rmi -f $(DANGLING_IMAGES)

clean: tidy ## Removes all container images associated with this repo
	docker image prune -f
	docker rmi -f $(REPO_IMAGES)
