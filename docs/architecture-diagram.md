Client
   |
   v
10.10.8.200
(MetalLB)
   |
Ingress NGINX
   |
+-------------------+
|   Kubernetes      |
|                   |
|  WordPress Pods   |
|        |          |
|        v          |
|     MySQL         |
+-------------------+
        |
        v
NFS Server
10.10.8.100