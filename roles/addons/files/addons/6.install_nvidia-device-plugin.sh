#!/bin/bash


# 下载 nvidia-device-plugin
# helm repo add nvdp https://nvidia.github.io/k8s-device-plugin
# helm pull nvdp/nvidia-device-plugin --version 0.18.0


# cat > runtimeclass.yaml <<EOF
# apiVersion: node.k8s.io/v1
# kind: RuntimeClass
# metadata:
#   name: nvidia
# handler: nvidia
# EOF

# kubectl apply -f runtimeclass.yaml



# tar -xf nvidia-device-plugin-0.18.0.tgz

# cd nvidia-device-plugin
 
# 将 runtimeClassName: null 修改为 runtimeClassName: nvidia
# sed -i 's/runtimeClassName: null/runtimeClassName: nvidia/g' values.yaml

# 将 values.yaml 中的 64到85行注释掉
# sed -i '64,85s/^/#/g' values.yaml

# 安装 nvidia-device-plugin
# helm install nvidia-device-plugin -n kube-system .


# kubectl label nodes <node-name> feature.node.kubernetes.io/pci-10de.present=true

# kubectl label nodes <node-name> feature.node.kubernetes.io/cpu-model.vendor_id=NVIDIA

# kubectl label nodes <node-name> nvidia.com/gpu.present=true