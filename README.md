# Switchboard Helm Manifest

## Setup

```bash
helm repo add vm https://victoriametrics.github.io/helm-charts/
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo add stable https://charts.helm.sh/stable
helm repo update
```

## Env

customers must modify:

- helm/grafana-values.yaml (username/password, ingress/tls hosts)
- helm/nginx-values.yaml (loadBalancerIP, certs, possibly setAsDefaultIngress)
- helm/switchboard-oracle/values.yaml (pretty much everything)

## Install

```bash
helm install grafana grafana/grafana -f helm/grafana-values.yaml
kubectl apply -f dashboard.yaml -n grafana
helm install vmsingle vm/victoria-metrics-single -f helm/vmetrics-values.yaml
helm install nginx-helm nginx-stable/nginx-ingress -f helm/nginx-values.yaml
helm install switchboard-oracle helm/switchboard-oracle -f helm/switchboard-oracle/values.yaml
```

## Other

todo: set resource requests for init/sidecar containers
