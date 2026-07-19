#!/bin/bash

# helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# helm pull prometheus-community/prometheus


tar -xf prometheus-29.18.0.tgz
cd prometheus

# 修改配置：
# vim values.yaml
# server:
#   persistentVolume:
#     enabled: true
#     statefulSetNameOverride: ""
#     accessModes:
#       - ReadWriteOnce
#     labels: {}
#     annotations: {}
#     existingClaim: ""
#     mountPath: /data
#     size: 8Gi
#     storageClass: "openebs-hostpath"
#     subPath: ""


# alertmanager:
#   enabled: true
#   persistence:
#     enabled: true
#     annotations: {}
#     labels: {}
#     storageClass: "openebs-hostpath"
#     accessModes:
#       - ReadWriteOnce
#     size: 2Gi


sed -i 's/    # storageClass: "-"/    # storageClass: "openebs-hostpath"/' values.yaml

helm install prometheus . -n monitoring --create-namespace
