#!/bin/bash

# helm repo add grafana https://grafana.github.io/helm-charts
# helm pull grafana/grafana

tar -xf grafana-*.tgz

cd grafana

kubectl create namespace monitoring
helm install grafana --namespace monitoring .


# kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo