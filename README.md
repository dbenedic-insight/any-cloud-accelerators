# any-cloud-accelerators
A collection of tools for accelerating cloud adoption, not limited to one cloud

## To build
From the root of the repository directory, simply run `make <accelerator>`.

For example, `make terraform` will build the version of Terraform specified in the Makefile and output a container image with the name `aca-terraform:<version>`.

## Prerequisites
You will need:
1. [Docker Desktop](https://www.docker.com/products/docker-desktop) or [equivalent](https://rancherdesktop.io/)
1. A POSIX-compliant terminal
1. [make](https://www.gnu.org/software/make/)

## To override versions and other defaults
All of the VARS in the Makefile can be overridden with environment variables from your shell.

For example:
```
export TERRAFORM_VERSION=0.13.4
make terraform
```
Will build `aca-terraform:0.13.4`.

This is powerful when combined with other tools such as [direnv](https://direnv.net) which allow you to export environment variables per directory. This allows you to have customized accelerators per project!

Typically I will clone this repo only once, then symlink it into each project directory where I'm leveraging direnv. That way I can simply `make <accelerator>` from within that project directory with the environment variable overrides I want for that project, e.g. from a project directory:
```
ln -s ~/Dev/github/dbenedic-insight/any-cloud-accelerators/Makefile .

ln -s ~/Dev/github/dbenedic-insight/any-cloud-accelerators/common .

ln -s ~/Dev/github/dbenedic-insight/any-cloud-accelerators/azure .

make az-tf-dev
```

**NOTE** I recommend overriding the `IMAGE_PREFIX` variable for each project when using direnv. This makes it easier to figure out which containers belong to which project when inspecting with `docker images`.

This also makes it easy to run your containers using ENV VARS, e.g.:
```
docker run --rm -it -v ~/.azure:/root/.azure -v ~/.terraform.d:/root/.terraform.d "${IMAGE_PREFIX}-az-tf-dev:${TERRAFORM_VERSION}"
```

# Grokking the docker image hierarchy
In this repo, all the Dockerfiles are built off of the image created by `common/base/Dockerfile`. This is where you will find the ENV VAR paths for things that are shared amongst multiple Dockerfiles (python, openssl, etc).

It was done this way so that if the base image was changed, it would trigger changes on everything built on top of it.

The components that make up a new Dockerfile can be pulled from these images in [multi-stage container builds](https://docs.docker.com/develop/develop-images/multistage-build/). This was done intentionally. All components are not included in the base image in order to keep container sizes down. Rule of thumb: if you need something in your container, pull it from one of these intermediate containers, don't just throw everything into one giant container.
