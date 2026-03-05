#!/usr/bin/env bash
set -euo pipefail

NS="${1:-mini-cloud}"

kubectl get ns "${NS}" >/dev/null 2>&1 || kubectl create ns "${NS}"

echo "[1/2] DNS test"
kubectl -n "${NS}" run dns-test --image=busybox:1.36 --restart=Never --command -- sh -c \
  "nslookup kubernetes.default.svc.cluster.local && sleep 1" >/dev/null
kubectl -n "${NS}" logs dns-test
kubectl -n "${NS}" delete pod dns-test >/dev/null

echo "[2/2] Scheduling test"
kubectl -n "${NS}" create deploy sched-test --image=nginx --replicas=3 >/dev/null
kubectl -n "${NS}" rollout status deploy/sched-test
kubectl -n "${NS}" get pods -o wide
kubectl -n "${NS}" delete deploy sched-test >/dev/null
