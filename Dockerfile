FROM ubuntu:noble

ARG CONTAINER_VERSION="0.0.0"

LABEL Author='Maciej Rachuna'
LABEL Application='pl.rachuna-net.containers.terraform'
LABEL Description='terraform container image'
LABEL version="${CONTAINER_VERSION}"


# Install packages
RUN apt-get update && apt-get install -y \
        curl \
        git \
        gnupg2 \
        lsb-release \
        openssh-client \
# Add repository hashicorp
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list \
# Install Terraform
    && apt-get update && apt-get install -y terraform \
    && apt-get upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -u 1001 -m -s /bin/bash nonroot

USER nonroot