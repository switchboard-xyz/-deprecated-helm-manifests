#!/bin/bash

set -e

stty sane # dont show backspace char during prompts

scriptDir=$(dirname "$0")

## Get Project Name
project=$1
if [ -z "$project" ];
then
  read -rp "Enter the name for the google cloud project (Ex. switchboard-oracle-cluster): " project
fi
project=$(echo "${project// /-}" | awk '{print tolower($0)}') # Replace spaces with dashes and make lower case
echo -e "project name: $project"

## Get TLS Domain Name
# domain=$2
# if [ -z "$domain" ];
# then
#   read -rp "Enter your registered domain name where you will view grafana metrics (Ex. grafana.switchboard.com): " domain
# fi
# echo -e "domain: $domain"

## Create TLS Certificate
mkdir -p secrets
tls_privkey_file=$(realpath "secrets/${project}-tls.private.key")
tls_pubkey_file=$(realpath "secrets/${project}-tls.public.key")
if [ ! -s "$tls_privkey_file" ]; then
    openssl genrsa 4096 > "$tls_privkey_file"
fi
tls_pubkey=$(openssl rsa -in "$tls_privkey_file" -pubout)
echo "$tls_pubkey" > "$tls_pubkey_file"
printf '\nAccount Public Key:\n%s\n\n' "$tls_pubkey"

tls_csr_file=$(realpath "secrets/${project}-tls.csr.pem")
if [ ! -s "$tls_csr_file" ]; then
    openssl req -new -nodes -key "$tls_privkey_file" -out "$tls_csr_file"
fi
tls_csr=$(<"$tls_csr_file")
printf '\nCertificate Signing Request:\n%s\n' "$tls_csr"

printf '\nPrivate Key File: %s' "$tls_privkey_file"
printf '\nPublic Key File: %s' "$tls_pubkey_file"
printf '\nCert Signing Request File: %s' "$tls_csr_file"

echo -e "\n\ncomplete the steps to sign your tls certificate https://gethttpsforfree.com"