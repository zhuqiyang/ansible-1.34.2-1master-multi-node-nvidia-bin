#!/bin/bash


# helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
# helm repo update

# helm pull nvidia/gpu-operator


cd gpu-operator

helm install gpu-operator nvidia/gpu-operator \
  --namespace gpu-operator \
  --create-namespace \
  --set driver.enabled=true \
  --set toolkit.enabled=true \
  --set devicePlugin.enabled=true \
  --set dcgmExporter.enabled=true \
  --set node-feature-discovery.enabled=true