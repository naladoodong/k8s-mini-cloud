# Phase Log

## Phase 0 – Cluster Baseline

- Kubernetes cluster initialized
- master + 3 worker nodes
- container runtime: containerd

---

## Phase 1 – Project Initialization

- git repository initialized
- project structure created
- cluster snapshot script created
- verification script created

---

## Phase 2 – MetalLB

- MetalLB already installed
- IP Pool configured

10.10.8.200-10.10.8.210

- ingress-nginx LoadBalancer allocated IP

10.10.8.200

---

## Phase 3 – Ingress

- ingress-nginx controller running
- service type LoadBalancer
- external traffic verified

curl http://10.10.8.200

---

## Phase 4 – Storage

NFS server deployed

10.10.8.100

Export

/srv/nfs/wordpress

Static PV/PVC created

pv-wp-nfs
pvc-wp

Mount test successful via test pod