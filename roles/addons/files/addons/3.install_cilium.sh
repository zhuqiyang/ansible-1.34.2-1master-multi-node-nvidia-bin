#!/bin/bash

# 安装 cilium
tar -xf cilium-*.tgz
cd cilium/

# 替换镜像地址
sed -i "s#quay.io/#docker.gh-proxy.org\/quay.io/#g" values.yaml

# 安装 cilium
helm install cilium . --namespace kube-system --set hubble.relay.enabled=true --set hubble.ui.enabled=true --set prometheus.enabled=true --set operator.prometheus.enabled=true --set hubble.enabled=true --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,http}"

kubectl scale deployment -n kube-system cilium-operator --replicas 1
