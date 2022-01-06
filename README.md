# Switchboard Helm Manifest

## Setup

You will need to first setup a GCP project and provision your account. The following script will walk you through the steps, where PROJECTNAME contains no spaces or special characters and will be the name of your GCP project:

```bash
./setup-gcloud.sh PROJECTNAME
```

Upon succesful completion, you will have an env file containing your google cloud configuration. You will need to manually add

- RPC_URL
- ORACLE_KEY

Next we will need to provision the TLS certificate to view the Grafana dashboard

```bash
./setup-grafana.sh PROJECTNAME DOMAIN EMAIL
```

Follow the instructions then add the following outputted variables to the env file:

- GRAFANA_HOSTNAME (your domain/subdomain that will host your grafana dashboard)
- GRAFANA_ADMIN_PASSWORD (can be set to any string used to login to the admin account)
- GRAFANA_TLS_CRT
- GRAFANA_TLS_KEY

## Deploy

Using the same `PROJECTNAME` as above, run the following command to build the helm charts for your deployment:

```bash
./build-helm.sh PROJECTNAME
```

Then deploy your helm charts to your GCP cluster:

```bash
./deploy-helm.sh PROJECTNAME
```
