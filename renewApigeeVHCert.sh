#!/bin/bash

# Input validation
if [ $# -ne 3 ]; then
    echo "Usage: $0 certificate_name key_name environment_group"
    exit 1
fi

cert_name=$1
key_name=$2
env_group=$3

# Check if certificate and key files exist
if [ ! -f ~/hybrid-files/certs/$cert_name.pem ]; then
    echo "Error: $cert_name.pem is not a valid file"
    exit 1
fi

if [ ! -f ~/hybrid-files/certs/$key_name.pem ]; then
    echo "Error: $key_name.pem is not a valid file"
    exit 1
fi

# Validate that the environment group name matches the certificate CN
cert_cn=$(openssl x509 -noout -subject -in ~/hybrid-files/certs/$cert_name.pem | grep "CN=" | awk -F "CN=" '{print $2}')

if [ "$cert_cn" != "$env_group" ]; then
    echo "Error: The environment group name does not match the certificate CN"
    exit 1
fi

# Validate that the certificate is valid
valid_from=$(openssl x509 -noout -dates -in ~/hybrid-files/certs/$cert_name.pem | grep "notBefore" | awk -F "=" '{print $2}')
valid_to=$(openssl x509 -noout -dates -in ~/hybrid-files/certs/$cert_name.pem | grep "notAfter" | awk -F "=" '{print $2}')

valid_from_epoch=$(date --date="$valid_from" +%s)
valid_to_epoch=$(date --date="$valid_to" +%s)
current_time_epoch=$(date +%s)

if [ $valid_from_epoch -gt $current_time_epoch ] || [ $valid_to_epoch -lt $current_time_epoch ]; then
    echo "Error: The certificate is not valid"
    exit 1
fi

# Get the current virtual host configuration
~/apigeectl/apigeectl get virtualhost -o yaml -n $env_group > ~/hybrid-files/overrides/overrides.yaml

# backup the overrides file
cp ~/hybrid-files/overrides/overrides.yaml ~/hybrid-files/overrides/overrides.yaml.bak

# update the overrides file
sed -i "s/certName:.*/certName: $cert_name/g" ~/hybrid-files/overrides/overrides.yaml
sed -i "s/keyName:.*/keyName: $key_name/g" ~/hybrid-files/overrides/overrides.yaml

# Dry run the changes
~/apigeectl/apigeectl apply -f ~/hybrid-files/overrides/overrides.yaml -dry-run

# Ask for confirmation
read -p "Apply the changes? [y/n]: " confirm
if [ "$confirm" == "y" ];

