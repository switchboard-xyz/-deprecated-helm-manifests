#!/bin/bash

set -e

stty sane # dont show backspace char during prompts

scriptDir=$(dirname "$0")

## Get Project Name
configName=$1
if [[ -z "${configName}" ]]; then
  read -rp "Enter the name for the google cloud project (Ex. switchboard-oracle-cluster): " configName
fi
configName=$(echo "${configName// /-}" | awk '{print tolower($0)}') # Replace spaces with dashes and make lower case
echo -e "config name: $configName"

envFile="$configName.env"
if [ -f "$envFile" ]
then
    envFile=$(realpath "${envFile}")
    echo "env File: $envFile"
else
    echo "failed to find env file: $envFile"
    exit 1
fi

set -a
. "$envFile"
set +a

if [[ -z "${PAGERDUTY_EVENT_KEY}" ]]; then
  PAGERDUTY_EVENT_KEY="UNDEFINED"
fi
if [[ -z "${ORACLE_KEY}" ]]; then
  echo "failed to set ORACLE_KEY"
  exit 1
fi
if [[ -z "${RPC_URL}" ]]; then
  echo "failed to set RPC_URL"
  exit 1
fi
if [[ -z "${GOOGLE_PAYER_SECRET_PATH}" ]]; then
  echo "failed to set GOOGLE_PAYER_SECRET_PATH"
  exit 1
fi
if [[ -z "${SERVICE_ACCOUNT_BASE64}" ]]; then
  echo "failed to set SERVICE_ACCOUNT_BASE64"
  exit 1
fi
if [[ -z "${EXTERNAL_IP}" ]]; then
  echo "failed to set EXTERNAL_IP"
  exit 1
fi
if [[ -z "${GRAFANA_HOSTNAME}" ]]; then
  echo "failed to set GRAFANA_HOSTNAME"
  exit 1
fi

prefix="kubernetes-"
outputPath=$(realpath "$prefix$configName")
echo "output Path: $outputPath";

mkdir -p "$outputPath"
cp -r "${scriptDir}/helm/" "$outputPath/"

files=(
"$outputPath/dashboard.yaml"
"$outputPath/grafana-values.yaml"
"$outputPath/nginx-values.yaml"
"$outputPath/vmetrics-values.yaml"
"$outputPath/switchboard-oracle/values.yaml"
)

for f in "${files[@]}"; do
  envsubst '$CLUSTER $RPC_URL $ORACLE_KEY $GOOGLE_PAYER_SECRET_PATH $SERVICE_ACCOUNT_BASE64 $EXTERNAL_IP $PAGERDUTY_EVENT_KEY $GRAFANA_HOSTNAME $GRAFANA_ADMIN_PASSWORD $GRAFANA_TLS_CRT $GRAFANA_TLS_KEY' < "$f" | tee "$outputPath/tmp.txt" ;
  cat "$outputPath/tmp.txt" > "$f";
done

rm "$outputPath/tmp.txt"
