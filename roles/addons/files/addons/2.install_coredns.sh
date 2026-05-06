#!/bin/bash

. addon_vars.sh

# 安装 coredns
tar -xf coredns-*.tgz
cd coredns/

# 替换镜像地址
sed -i "s#registry.k8s.io/#docker.gh-proxy.org/#g" values.yaml
sed -i "s#coredns\/coredns#docker.gh-proxy.org\/docker.io\/coredns\/coredns#g" values.yaml

# 安装 coredns
helm install coredns . -n kube-system --set service.clusterIP=${dns_clusterip}

# 扩容 coredns
kubectl scale deployment -n kube-system coredns --replicas 1
