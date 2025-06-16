#!/usr/bin/env bash
echo "🧪 Testing Terraform container image"
terraform --version

echo "🧪 Testing CA"
curl -s https://vault.rachuna-net.pl/
