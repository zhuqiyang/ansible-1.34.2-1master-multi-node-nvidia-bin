#!/bin/bash

# helm repo add kedacore https://kedacore.github.io/charts
# helm pull kedacore/keda

tar -xf keda-2.20.1.tgz
cd keda

helm install keda . \
  --namespace keda \
  --create-namespace \
  --set resources.operator.requests.cpu=100m \
  --set resources.operator.requests.memory=128Mi \
  --set metricsAdapter.podIdentity.activeDirectory.enabled=false