#!/bin/bash

set -e

stty sane # dont show backspace char during prompts

## Get Project Name
project=$1
if [ -z "$project" ];
then
  read -rp "Enter the name for the google cloud project (Ex. switchboard-oracle-cluster): " project
fi
project=$(echo "${project// /-}" | awk '{print tolower($0)}') # Replace spaces with dashes and make lower case
echo -e "project name: $project"

## Create TLS Certificate
mkdir -p secrets
tls_privkey_file=$(realpath "secrets/${project}-letsencrypt.private.key")
tls_pubkey_file=$(realpath "secrets/${project}-tls.public.pub")
if [ ! -s "$tls_privkey_file" ]; then
    openssl genrsa 4096 > "$tls_privkey_file"
fi
tls_pubkey=$(openssl rsa -in "$tls_privkey_file" -pubout)
echo "$tls_pubkey" > "$tls_pubkey_file"
printf '\nAccount Public Key:\n%s\n\n' "$tls_pubkey"

csr_privkey_file=$(realpath "secrets/${project}-csr.private.key")
csr_file=$(realpath "secrets/${project}-csr.pem")
if [ ! -s "$csr_privkey_file" ]; then
    openssl genrsa 4096 > "$csr_privkey_file"
fi
if [ ! -s "$csr_file" ]; then
    domain=$2
    read -rp "is this domain correct (${domain})? (y/n)? " answer
    case ${answer:0:1} in
        y|Y )
        ;;
        * )
            read -rp "Enter your registered domain name where you will view grafana metrics (Ex. grafana.switchboard.com): " domain
        ;;
    esac
    email=$3
    read -rp "is this email correct (${email})? (y/n)? " answer
    case ${answer:0:1} in
        y|Y )
        ;;
        * )
            read -rp "Enter an email for your TLS CRT: " email
        ;;
    esac
    openssl req -new -nodes -key "$csr_privkey_file" -out "$csr_file" -subj "/CN=${domain}/emailAddress=${email}"
fi
tls_csr=$(<"$csr_file")
printf '\nCertificate Signing Request:\n%s\n' "$tls_csr"

printf '\nPrivate Key File: %s' "$tls_privkey_file"
printf '\nPublic Key File: %s' "$tls_pubkey_file"
printf '\nCert Signing Request File: %s' "$csr_file"

echo -e "\n\ncomplete the steps to sign your tls certificate https://gethttpsforfree.com"

echo -e "\n\texport PRIV_KEY=$tls_privkey_file"

crt_file=$(realpath "secrets/${project}-domain.crt")
key_file=$(realpath "secrets/${project}-intermediate.key")

if [[ ! -f "$crt_file" || ! -s "$crt_file" ]]; then
    printf '\ncomplete the steps and save the tls cert files to:\n\t%s\n\t%s\n' "$crt_file" "$key_file"
    exit 0
fi
grafana_tls_crt=$(base64 "$crt_file")
grafana_tls_crt_str=$(printf 'GRAFANA_TLS_CRT="%s"' "$grafana_tls_crt")
echo "$grafana_tls_crt_str"

if [[ ! -f "$key_file" || ! -s "$key_file" ]]; then
    printf '\ncomplete the steps and save the tls cert files to:\n\t%s\n\t%s\n' "$crt_file" "$key_file"
    exit 0
fi
grafana_tls_key=$(base64 "$key_file")
grafana_tls_key_str=$(printf 'GRAFANA_TLS_KEY="%s"' "$grafana_tls_key")
echo "$grafana_tls_key_str"


# outEnvFile="${project}.env"
# # echo $(awk -v replace="$grafana_tls_crt_str" 'sub(/^GRAFANA_TLS_CRT=.*$|$/,replace)' "$outEnvFile") > "$outEnvFile"
# sed -Ei '' "s/(^GRAFANA_TLS_KEY=.*$)/GRAFANA_TLS_KEY=\"$grafana_tls_key\"\n/" "$outEnvFile"
# # printf 'GRAFANA_HOSTNAME="%s"\n' "$domain" | sed -Ei '' "s/(^GRAFANA_HOSTNAME=.*$)/\1/" "$outEnvFile"

# echo -e "\n\nEnvironment variables saved to ${outEnvFile}"
