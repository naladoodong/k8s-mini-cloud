#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="00-cluster"
mkdir -p "$OUT_DIR"

ts="$(date +%Y%m%d-%H%M%S)"

kubectl version  | tee "${OUT_DIR}/version-${ts}.txt"
kubectl get nodes -o wide | tee "${OUT_DIR}/nodes-${ts}.txt"
kubectl get ns | tee "${OUT_DIR}/ns-${ts}.txt"

kubectl get pods -A -o wide | tee "${OUT_DIR}/pods-${ts}.txt"
kubectl get svc -A -o wide | tee "${OUT_DIR}/svc-${ts}.txt"
kubectl get deploy,rs,ds,sts -A -o wide | tee "${OUT_DIR}/workloads-${ts}.txt"
kubectl get pvc,pv -A -o wide | tee "${OUT_DIR}/storage-${ts}.txt"
kubectl get ingress -A -o wide | tee "${OUT_DIR}/ingress-${ts}.txt"

kubectl get crd | tee "${OUT_DIR}/crd-${ts}.txt"
