#!/bin/bash
set -euo pipefail

proxy_url=https://gh-proxy.org/

k8s_version=v1.34.3
cfssl_version=1.6.5
cri_dockerd_version=0.3.20
docker_version=29.2.0
etcd_version=3.6.4
cni_version=1.7.1
nerdctl_version=2.2.1
crictl_version=1.34.0
containerd_version=2.0.5
runc_version=1.1.12
cilium_version=0.18.9

# 所有下载的文件统一放在当前目录下的 download 目录中
DOWNLOAD_DIR="$(pwd)/download"
mkdir -p "${DOWNLOAD_DIR}"

# ============================================================
# 辅助函数
# ============================================================
# 下载单个文件（已存在则跳过）
# 用法: download_file <保存路径> <下载URL>
download_file() {
    local dest="$1"
    local url="$2"
    if [ -f "${dest}" ]; then
        # 已存在的文件在预检查阶段已报告，此处静默跳过
        return 0
    fi
    echo "  [下载] $(basename "${dest}")  <-  ${url}"
    wget -O "${dest}" "${url}"
}

# ============================================================
# 打印资源下载清单
# ============================================================
echo "============================================"
echo "  资源下载清单"
echo "============================================"
echo ""
echo "  版本信息:"
echo "    Kubernetes : ${k8s_version}"
echo "    Docker     : ${docker_version}"
echo "    Containerd : ${containerd_version}"
echo "    RunC       : ${runc_version}"
echo "    CNI        : ${cni_version}"
echo "    ETCD       : ${etcd_version}"
echo "    CFSSL      : ${cfssl_version}"
echo "    CRI-Dockerd: ${cri_dockerd_version}"
echo "    Nerdctl    : ${nerdctl_version}"
echo "    Crictl     : ${crictl_version}"
echo "    Cilium CLI : ${cilium_version}"
echo ""
echo "  将要下载的资源:"
echo "    1. cfssl                  (Cloudflare)          v${cfssl_version}"
echo "       ${proxy_url}https://github.com/cloudflare/cfssl/releases/download/v${cfssl_version}/cfssl_${cfssl_version}_linux_amd64"
echo "    2. cfssljson              (Cloudflare)          v${cfssl_version}"
echo "       ${proxy_url}https://github.com/cloudflare/cfssl/releases/download/v${cfssl_version}/cfssljson_${cfssl_version}_linux_amd64"
echo "    3. cri-dockerd            (Mirantis)            v${cri_dockerd_version}"
echo "       ${proxy_url}https://github.com/Mirantis/cri-dockerd/releases/download/v${cri_dockerd_version}/cri-dockerd-${cri_dockerd_version}.amd64.tgz"
echo "    4. docker                 (Docker Inc.)         v${docker_version}"
echo "       https://download.docker.com/linux/static/stable/x86_64/docker-${docker_version}.tgz"
echo "    5. etcd/etcdctl/etcdutl   (etcd-io)             v${etcd_version}"
echo "       ${proxy_url}https://github.com/etcd-io/etcd/releases/download/v${etcd_version}/etcd-v${etcd_version}-linux-amd64.tar.gz"
echo "    6. cni-plugins            (containernetworking) v${cni_version}"
echo "       ${proxy_url}https://github.com/containernetworking/plugins/releases/download/v${cni_version}/cni-plugins-linux-amd64-v${cni_version}.tgz"
echo "    7. kubernetes-server      (K8s Release)         ${k8s_version}"
echo "       https://dl.k8s.io/${k8s_version}/kubernetes-server-linux-amd64.tar.gz"
echo "    8. nerdctl                (containerd)          v${nerdctl_version}"
echo "       ${proxy_url}https://github.com/containerd/nerdctl/releases/download/v${nerdctl_version}/nerdctl-${nerdctl_version}-linux-amd64.tar.gz"
echo "    9. crictl/critest         (kubernetes-sigs)     v${crictl_version}"
echo "       ${proxy_url}https://github.com/kubernetes-sigs/cri-tools/releases/download/v${crictl_version}/crictl-v${crictl_version}-linux-amd64.tar.gz"
echo "   10. containerd             (containerd)          v${containerd_version}"
echo "       ${proxy_url}https://github.com/containerd/containerd/releases/download/v${containerd_version}/containerd-${containerd_version}-linux-amd64.tar.gz"
echo "   11. runc                   (opencontainers)      v${runc_version}"
echo "       ${proxy_url}https://github.com/opencontainers/runc/releases/download/v${runc_version}/runc.amd64"
echo "   12. cilium                 (cilium)              v${cilium_version}"
echo "       ${proxy_url}https://github.com/cilium/cilium-cli/releases/download/v${cilium_version}/cilium-linux-amd64.tar.gz"
echo ""
echo "  镜像代理: ${proxy_url}"
echo "  下载目录: ${DOWNLOAD_DIR}"
echo ""
echo "============================================"
echo ""

# ============================================================
# 阶段一：下载所有资源（全部下载成功后才进行后续操作）
# ============================================================
echo "============================================"
echo "  阶段一：下载所有资源"
echo "============================================"
echo ""

# 检查所有待下载文件是否已存在
# 若全部存在则直接跳过整个下载阶段
echo "--------------------------------------------"
echo "  预检查：扫描目标文件是否已存在"
echo "--------------------------------------------"

# 待检查的文件清单：文件名|标题
CHECK_LIST=(
    "cfssl|1. cfssl"
    "cfssljson|2. cfssljson"
    "cri-dockerd-${cri_dockerd_version}.amd64.tgz|3. cri-dockerd"
    "docker-${docker_version}.tgz|4. docker"
    "etcd-v${etcd_version}-linux-amd64.tar.gz|5. etcd"
    "cni-plugins-linux-amd64-v${cni_version}.tgz|6. cni-plugins"
    "kubernetes-server-linux-amd64.tar.gz|7. kubernetes-server"
    "nerdctl-${nerdctl_version}-linux-amd64.tar.gz|8. nerdctl"
    "crictl-v${crictl_version}-linux-amd64.tar.gz|9. crictl"
    "containerd-${containerd_version}-linux-amd64.tar.gz|10. containerd"
    "runc|11. runc"
    "cilium-linux-amd64.tar.gz|12. cilium"
)

exist_count=0
missing_count=0
missing_files=()

for entry in "${CHECK_LIST[@]}"; do
    filename="${entry%%|*}"
    title="${entry##*|}"
    if [ -f "${DOWNLOAD_DIR}/${filename}" ]; then
        printf "  %-24s [已存在]\n" "${title}"
        exist_count=$((exist_count + 1))
    else
        printf "  %-24s [待下载]\n" "${title}"
        missing_count=$((missing_count + 1))
        missing_files+=("${filename}")
    fi
done

echo "--------------------------------------------"
echo "  已存在: ${exist_count} 个    待下载: ${missing_count} 个"
echo "--------------------------------------------"
echo ""

# 全部已存在则跳过下载阶段
if [ "${missing_count}" -eq 0 ]; then
    echo "所有资源均已存在，跳过下载阶段。"
    echo ""
else
    echo "开始下载缺失的资源..."
    echo ""

# 1. cfssl
download_file "${DOWNLOAD_DIR}/cfssl" \
    "${proxy_url}https://github.com/cloudflare/cfssl/releases/download/v${cfssl_version}/cfssl_${cfssl_version}_linux_amd64"

# 2. cfssljson
download_file "${DOWNLOAD_DIR}/cfssljson" \
    "${proxy_url}https://github.com/cloudflare/cfssl/releases/download/v${cfssl_version}/cfssljson_${cfssl_version}_linux_amd64"

# 3. cri-dockerd
download_file "${DOWNLOAD_DIR}/cri-dockerd-${cri_dockerd_version}.amd64.tgz" \
    "${proxy_url}https://github.com/Mirantis/cri-dockerd/releases/download/v${cri_dockerd_version}/cri-dockerd-${cri_dockerd_version}.amd64.tgz"

# 4. docker
download_file "${DOWNLOAD_DIR}/docker-${docker_version}.tgz" \
    "${proxy_url}https://download.docker.com/linux/static/stable/x86_64/docker-${docker_version}.tgz"

# 5. etcd
download_file "${DOWNLOAD_DIR}/etcd-v${etcd_version}-linux-amd64.tar.gz" \
    "${proxy_url}https://github.com/etcd-io/etcd/releases/download/v${etcd_version}/etcd-v${etcd_version}-linux-amd64.tar.gz"

# 6. cni-plugins
download_file "${DOWNLOAD_DIR}/cni-plugins-linux-amd64-v${cni_version}.tgz" \
    "${proxy_url}https://github.com/containernetworking/plugins/releases/download/v${cni_version}/cni-plugins-linux-amd64-v${cni_version}.tgz"

# 7. kubernetes-server
download_file "${DOWNLOAD_DIR}/kubernetes-server-linux-amd64.tar.gz" \
    "${proxy_url}https://dl.k8s.io/${k8s_version}/kubernetes-server-linux-amd64.tar.gz"

# 8. nerdctl
download_file "${DOWNLOAD_DIR}/nerdctl-${nerdctl_version}-linux-amd64.tar.gz" \
    "${proxy_url}https://github.com/containerd/nerdctl/releases/download/v${nerdctl_version}/nerdctl-${nerdctl_version}-linux-amd64.tar.gz"

# 9. crictl
download_file "${DOWNLOAD_DIR}/crictl-v${crictl_version}-linux-amd64.tar.gz" \
    "${proxy_url}https://github.com/kubernetes-sigs/cri-tools/releases/download/v${crictl_version}/crictl-v${crictl_version}-linux-amd64.tar.gz"

# 10. containerd
download_file "${DOWNLOAD_DIR}/containerd-${containerd_version}-linux-amd64.tar.gz" \
    "${proxy_url}https://github.com/containerd/containerd/releases/download/v${containerd_version}/containerd-${containerd_version}-linux-amd64.tar.gz"

# 11. runc
download_file "${DOWNLOAD_DIR}/runc" \
    "${proxy_url}https://github.com/opencontainers/runc/releases/download/v${runc_version}/runc.amd64"

# 12. cilium
download_file "${DOWNLOAD_DIR}/cilium-linux-amd64.tar.gz" \
    "${proxy_url}https://github.com/cilium/cilium-cli/releases/download/v${cilium_version}/cilium-linux-amd64.tar.gz"

echo ""
echo "所有资源下载完成。"
echo ""
fi

# ============================================================
# 阶段二：解压并整理归档文件
# ============================================================
echo "============================================"
echo "  阶段二：解压并整理归档文件"
echo "============================================"
echo ""

# cri-dockerd：解压后把 cri-dockerd/cri-dockerd 提到 download 根目录
if [ ! -f "${DOWNLOAD_DIR}/cri-dockerd" ]; then
    echo "  [解压] cri-dockerd-${cri_dockerd_version}.amd64.tgz"
    tar -xf "${DOWNLOAD_DIR}/cri-dockerd-${cri_dockerd_version}.amd64.tgz" -C "${DOWNLOAD_DIR}"
    mv "${DOWNLOAD_DIR}/cri-dockerd" "${DOWNLOAD_DIR}/cridockerd"
    cp "${DOWNLOAD_DIR}/cridockerd/cri-dockerd" "${DOWNLOAD_DIR}/cri-dockerd"
    rm -rf "${DOWNLOAD_DIR}/cridockerd"
else
    echo "  [跳过] 已解压: cri-dockerd"
fi

# docker：解压后生成 docker/ 目录
if [ ! -d "${DOWNLOAD_DIR}/docker" ]; then
    echo "  [解压] docker-${docker_version}.tgz"
    tar -xf "${DOWNLOAD_DIR}/docker-${docker_version}.tgz" -C "${DOWNLOAD_DIR}"
else
    echo "  [跳过] 已解压: docker"
fi

# etcd：解压后把 etcd/etcdctl/etcdutl 提到 download 根目录
if [ ! -f "${DOWNLOAD_DIR}/etcd" ]; then
    echo "  [解压] etcd-v${etcd_version}-linux-amd64.tar.gz"
    tar -xf "${DOWNLOAD_DIR}/etcd-v${etcd_version}-linux-amd64.tar.gz" -C "${DOWNLOAD_DIR}/"
    mv "${DOWNLOAD_DIR}/etcd-v${etcd_version}-linux-amd64"/{etcd,etcdctl,etcdutl} "${DOWNLOAD_DIR}/"
    rm -rf "${DOWNLOAD_DIR}/etcd-v${etcd_version}-linux-amd64"
else
    echo "  [跳过] 已解压: etcd"
fi

# kubernetes-server：解压后把组件二进制提到 download 根目录
if [ ! -f "${DOWNLOAD_DIR}/kube-apiserver" ]; then
    echo "  [解压] kubernetes-server-linux-amd64.tar.gz"
    tar -xf "${DOWNLOAD_DIR}/kubernetes-server-linux-amd64.tar.gz" -C "${DOWNLOAD_DIR}"
    cp "${DOWNLOAD_DIR}/kubernetes/server/bin"/{kube-apiserver,kube-controller-manager,kubectl,kubelet,kube-proxy,kube-scheduler} "${DOWNLOAD_DIR}"
    rm -rf "${DOWNLOAD_DIR}/kubernetes"
else
    echo "  [跳过] 已解压: kubernetes-server"
fi

# nerdctl：解压后生成 nerdctl 二进制
if [ ! -f "${DOWNLOAD_DIR}/nerdctl" ]; then
    echo "  [解压] nerdctl-${nerdctl_version}-linux-amd64.tar.gz"
    tar -xf "${DOWNLOAD_DIR}/nerdctl-${nerdctl_version}-linux-amd64.tar.gz" -C "${DOWNLOAD_DIR}"
else
    echo "  [跳过] 已解压: nerdctl"
fi

# crictl：解压后把 crictl/critest 提到 download 根目录
if [ ! -f "${DOWNLOAD_DIR}/crictl" ]; then
    echo "  [解压] crictl-v${crictl_version}-linux-amd64.tar.gz"
    tar -xf "${DOWNLOAD_DIR}/crictl-v${crictl_version}-linux-amd64.tar.gz" -C "${DOWNLOAD_DIR}"
else
    echo "  [跳过] 已解压: crictl"
fi

# containerd：解压后把 bin/ 下的二进制提到 download 根目录
if [ ! -f "${DOWNLOAD_DIR}/containerd" ]; then
    echo "  [解压] containerd-${containerd_version}-linux-amd64.tar.gz"
    tar -xf "${DOWNLOAD_DIR}/containerd-${containerd_version}-linux-amd64.tar.gz" -C "${DOWNLOAD_DIR}"
    mv "${DOWNLOAD_DIR}/bin"/{containerd,containerd-shim-runc-v2,containerd-stress,ctr} "${DOWNLOAD_DIR}/"
    rm -rf "${DOWNLOAD_DIR}/bin"
else
    echo "  [跳过] 已解压: containerd"
fi

# cilium：解压后生成 cilium 二进制
if [ ! -f "${DOWNLOAD_DIR}/cilium" ]; then
    echo "  [解压] cilium-linux-amd64.tar.gz"
    tar -xf "${DOWNLOAD_DIR}/cilium-linux-amd64.tar.gz" -C "${DOWNLOAD_DIR}"
else
    echo "  [跳过] 已解压: cilium"
fi

# runc：直接下载的二进制，赋予执行权限
if [ -f "${DOWNLOAD_DIR}/runc" ]; then
    chmod +x "${DOWNLOAD_DIR}/runc"
fi

echo ""
echo "所有归档文件解压并整理完成。"
echo ""

# ============================================================
# 阶段三：安装到系统目录
# ============================================================
echo "============================================"
echo "  阶段三：安装到系统目录"
echo "============================================"
echo ""

# cfssl / cfssljson / kubectl 安装到 /usr/local/bin/
for bin in cfssl cfssljson kubectl; do
    if [ -f "${DOWNLOAD_DIR}/${bin}" ]; then
        chmod +x "${DOWNLOAD_DIR}/${bin}"
        cp "${DOWNLOAD_DIR}/${bin}" /usr/local/bin/
        echo "  [安装] ${bin} -> /usr/local/bin/"
    else
        echo "  [警告] 缺少文件，跳过: ${bin}"
    fi
done

echo ""
echo "============================================"
echo "  全部完成！"
echo "============================================"