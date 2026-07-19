#!/bin/bash

#export https_proxy=http://192.168.0.100:7897
#export http_proxy=http://192.168.0.100:7897

# 下载 cilium
helm repo add cilium https://helm.cilium.io
helm pull cilium/cilium

# 下载 coredns
helm repo add coredns https://coredns.github.io/helm
helm pull coredns/coredns

# 下载 ingress-nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm pull ingress-nginx/ingress-nginx

# 下载 nvidia-device-plugin
helm repo add nvdp https://nvidia.github.io/k8s-device-plugin
helm pull nvdp/nvidia-device-plugin --version 0.18.0

# 下载 openebs
helm repo add openebs https://openebs.github.io/openebs
helm pull openebs/openebs

# 系在 prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm pull prometheus-community/prometheus

# 下载 minio
helm repo add bitnami https://charts.bitnami.com/bitnami
helm pull bitnami/minio

# 下载 metrics-server
# wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml -O metrics-server.yaml
