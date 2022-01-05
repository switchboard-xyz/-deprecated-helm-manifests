#!/bin/bash

set -e

## Get Project Name
configName=$1
if [[ -z "${configName}" ]]; then
  read -rp "Enter the name for the google cloud project (Ex. switchboard-oracle-cluster): " configName
fi
configName=$(echo "${configName// /-}" | awk '{print tolower($0)}') # Replace spaces with dashes and make lower case
echo -e "config name: $configName"

prefix="kubernetes-"
helmDir=$(realpath "$prefix$configName")
if [ -d "$helmDir" ]
then
    echo "helm directory: $helmDir";
else
    echo "failed to find helm directory: $helmDir"
    exit 1
fi

## Add / Update Helm Charts
helm repo add vm https://victoriametrics.github.io/helm-charts/
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo add stable https://charts.helm.sh/stable
helm repo update

## Deploy Helm Charts
# kubectl create ns grafana || true
helm install grafana grafana/grafana -f "$helmDir/grafana-values.yaml"
kubectl apply -f "$helmDir/dashboard.yaml" -n grafana
helm install vmsingle vm/victoria-metrics-single -f "$helmDir/vmetrics-values.yaml"
helm install nginx-helm nginx-stable/nginx-ingress -f "$helmDir/nginx-values.yaml"
helm install switchboard-oracle helm/switchboard-oracle -f "$helmDir/switchboard-oracle/values.yaml"

printf "\nHelm charts deployed from %s" "${helmDir}"