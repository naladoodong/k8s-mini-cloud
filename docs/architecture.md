# Kubernetes Mini Cloud Platform Architecture

## Cluster

Master
- master.labs.local (10.10.8.101)

Workers
- node1.labs.local (10.10.8.102)
- node2.labs.local (10.10.8.103)
- node3.labs.local (10.10.8.104)

## Network

Pod Network
- CNI: Cilium

LoadBalancer
- MetalLB (L2 mode)

IP Pool
- 10.10.8.200-10.10.8.210

Ingress
- ingress-nginx controller
- External IP: 10.10.8.200

## Storage

NFS Server
- 10.10.8.100

Export
- /srv/nfs/wordpress

Kubernetes Storage
- Static PV
- AccessMode: RWX