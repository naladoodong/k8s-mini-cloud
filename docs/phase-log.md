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

## Phase 5 - Mysql

### MySQL PVC binding issue

### Symptom
- mysql-0 pod stayed Pending
- Event: pod has unbound immediate PersistentVolumeClaims

### Cause
- pvc-mysql was first created in the `default` namespace because the namespace field was omitted
- pv-mysql-nfs got bound to `default/pvc-mysql`
- later, `mini-cloud/pvc-mysql` could not bind because the PV was already claimed

### Resolution
- deleted the incorrectly bound PV/PVC
- recreated PVC in the correct namespace (`mini-cloud`)
- recreated PV and PVC
- verified successful binding and pod scheduling

### Lesson learned
- PVC is namespace-scoped, PV is cluster-scoped
- Always verify namespace explicitly for application PVCs

## MySQL on NFS permission issue

### Symptom
- MySQL container failed during startup
- Error:
  - chown: changing ownership of '/var/lib/mysql': Operation not permitted

### Cause
- NFS export did not allow ownership change from the client side
- MySQL entrypoint tried to chown the datadir during initialization
- NFS root squash behavior blocked the operation

### Resolution
- Updated `/srv/nfs/mysql` export with `no_root_squash`
- Re-exported NFS shares
- Recreated MySQL pod

### Lesson learned
- Simple file write tests on NFS are not enough for stateful workloads
- Database containers often need ownership changes during initialization

## phase 6 - Wordpress

## WordPress HA Notes
- WordPress pods were distributed across node1, node2, and node3 as intended.
- podAntiAffinity and topologySpreadConstraints were effective for node-level spreading.
- Current design uses shared NFS storage for WordPress data.
- This is sufficient for MVP, but mounting the full document root is a simplification and may be refined later.
- HPA can scale the web tier, but MySQL remains a single backend and may become the bottleneck.