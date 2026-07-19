#!/bin/bash


# helm repo add openebs https://openebs.github.io/openebs
# helm repo update
# helm pull openebs/openebs


tar -xf openebs-4.5.0.tgz
cd openebs

helm install openebs --namespace openebs openebs/openebs \
  --set engines.replicated.mayastor.enabled=false \
  --set engines.local.zfs.enabled=false \
  --create-namespace