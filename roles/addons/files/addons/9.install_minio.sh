#!/bash

# helm repo add bitnami https://charts.bitnami.com/bitnami
# helm pull bitnami/minio

tar -xf minio-5.4.0.tgz
cd minio

helm install minio . \
  --namespace minio \
  --create-namespace \
  --set auth.rootUser=minioadmin \
  --set auth.rootPassword=minioadmin \
  --set mode=standalone \
  --set persistence.size=30Gi \
  --set persistence.storageClass=openebs-minio-localpv