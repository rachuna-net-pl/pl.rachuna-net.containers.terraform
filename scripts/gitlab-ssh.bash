#!/bin/bash

mkdir -p /root/.ssh
chmod 700 /root/.ssh
echo "$GITLAB_SSH_KEY" > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa

echo "Host gitlab.com IdentityFile /root/.ssh/id_rsa StrictHostKeyChecking no" > /root/.ssh/config
ssh-keyscan gitlab.com >> ~/.ssh/known_hosts