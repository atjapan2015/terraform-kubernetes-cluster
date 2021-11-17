#!/bin/bash -x

EXTERNAL_IP=$(curl -s -m 10 http://whatismyip.akamai.com/)
LOCAL_IP=$(ip route show to 0.0.0.0/0 | awk '{ print $5 }' | xargs ip addr show | grep -Po 'inet \K[\d.]+')
HOSTNAME=$(hostname -f)

# install docker
#mkdir /root/docker
#wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.4.9-3.1.el7.x86_64.rpm -O /root/docker/containerd.io-1.4.9-3.1.el7.x86_64.rpm
#wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-20.10.9-3.el7.x86_64.rpm -O /root/docker/docker-ce-20.10.9-3.el7.x86_64.rpm
#wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-cli-20.10.9-3.el7.x86_64.rpm -O /root/docker/docker-ce-cli-20.10.9-3.el7.x86_64.rpm
#wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-rootless-extras-20.10.9-3.el7.x86_64.rpm -O /root/docker/docker-ce-rootless-extras-20.10.9-3.el7.x86_64.rpm
#wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-scan-plugin-0.8.0-3.el7.x86_64.rpm -O /root/docker/docker-scan-plugin-0.8.0-3.el7.x86_64.rpm
#wget https://www.rpmfind.net/linux/centos/7.9.2009/extras/x86_64/Packages/container-selinux-2.119.2-1.911c772.el7_8.noarch.rpm -O /root/docker/container-selinux-2.119.2-1.911c772.el7_8.noarch.rpm
#wget https://www.rpmfind.net/linux/centos/7.9.2009/extras/x86_64/Packages/fuse-overlayfs-0.7.2-6.el7_8.x86_64.rpm -O /root/docker/fuse-overlayfs-0.7.2-6.el7_8.x86_64.rpm
#wget https://www.rpmfind.net/linux/centos/7.9.2009/extras/x86_64/Packages/slirp4netns-0.4.3-4.el7_8.x86_64.rpm -O /root/docker/slirp4netns-0.4.3-4.el7_8.x86_64.rpm
#wget http://mirror.centos.org/centos/7/extras/x86_64/Packages/fuse3-libs-3.6.1-4.el7.x86_64.rpm -O /root/docker/fuse3-libs-3.6.1-4.el7.x86_64.rpm
#sudo yum localinstall -y /root/docker/*.rpm

sudo yum install -y docker-engine

sudo systemctl enable --now docker
sudo usermod -a -G docker opc

cat <<EOF | sudo tee /etc/docker/daemon.json
{
   "exec-opts": ["native.cgroupdriver=systemd"],
   "log-driver": "json-file",
   "log-opts": {
     "max-size": "100m"
   },
   "storage-driver": "overlay2",
   "storage-opts": [
     "overlay2.override_kernel_check=true"
   ],
   "insecure-registries": ["0.0.0.0/0"]
}
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker

# install kubernetes
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

sudo yum install -y kubelet-1.21.6 kubeadm-1.21.6 kubectl-1.21.6 --disableexcludes=kubernetes
sudo systemctl enable --now kubelet

mkdir -p /root/k8s
cat <<EOF | sudo tee /root/k8s/kubeadm-init.yaml
apiVersion: kubeadm.k8s.io/v1beta2
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: $LOCAL_IP
  bindPort: 6443
nodeRegistration:
  criSocket: /var/run/dockershim.sock
  name: $HOSTNAME
  taints: null
---
apiServer:
  timeoutForControlPlane: 4m0s
  certSANs:
  - $EXTERNAL_IP
  - $LOCAL_IP
apiVersion: kubeadm.k8s.io/v1beta2
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /var/lib/etcd
    serverCertSANs:
    - $EXTERNAL_IP
    - $LOCAL_IP
imageRepository: k8s.gcr.io
kind: ClusterConfiguration
kubernetesVersion: 1.21.6
networking:
  dnsDomain: cluster.local
  serviceSubnet: 10.96.0.0/16
  podSubnet: 10.244.0.0/16
scheduler: {}
EOF

sudo yum install -y tc
kubeadm config images pull --config /root/k8s/kubeadm-init.yaml
kubeadm init --config /root/k8s/kubeadm-init.yaml

kubectl apply --kubeconfig /etc/kubernetes/admin.conf -f https://docs.projectcalico.org/manifests/canal.yaml

mkdir -p /root/.kube
sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config

mkdir -p /home/opc/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/opc/.kube/config
sudo chown opc:opc /home/opc/.kube/config

echo "source <(kubectl completion bash)" >>/home/opc/.bashrc
echo "alias k=kubectl" >>/home/opc/.bashrc
echo "complete -F __start_kubectl k" >>/home/opc/.bashrc

sudo kubeadm token create --print-join-command > /home/opc/join.sh
sudo chown opc:opc /home/opc/join.sh

sudo sed -i 's/'''$LOCAL_IP'''/'''$EXTERNAL_IP'''/g' /home/opc/.kube/config