# Decisions (ADR-lite)

## Naming / Labels
- project: k8s-mini-cloud
- component: metallb|ingress|nfs|mysql|wordpress|hpa|monitoring
- phase: 1..7

## Namespaces
- mini-cloud (apps)
- metallb-system
- ingress-nginx
- monitoring

## MetalLB
- AddressPool: 10.10.8.200-10.10.8.210 (L2 mode)
- Nodes: master 10.10.8.101, workers 10.10.8.102-104
- Ingress LB IP: 10.10.8.200 (ingress-nginx controller Service)

Reason
- Same L2 network as nodes
- Simple ARP based advertisement

## Ingress NGINX
- Installed via manifests (no Helm release detected)
- Controller image: registry.k8s.io/ingress-nginx/controller:v1.3.1
- LB IP: 10.10.8.200 via MetalLB

Reason
- widely used
- simple configuration
- good community support

External Access
- via MetalLB LoadBalancer

## Storage (NFS Static PV)
- NFS server: 10.10.8.100
- Export: /srv/nfs/wordpress (RWX)
- StorageClass: nfs-static (no-provisioner), ReclaimPolicy=Retain

WordPress storage uses NFS RWX volume.

Reason
- WordPress uploads require shared filesystem
- easier scaling for multiple replicas


## Notes
- Track why we chose each component and configuration.

