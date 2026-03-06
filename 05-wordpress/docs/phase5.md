Troubleshooting
1. PVC Namespace Binding Issue
Symptom

MySQL Pod가 Pending 상태로 계속 대기하고 스케줄되지 않음.

0/4 nodes are available: pod has unbound immediate PersistentVolumeClaims

Pod describe 결과:

Warning  FailedBinding  persistentvolume-controller
volume "pv-mysql-nfs" already bound to a different claim

PV 상태:

Status: Bound
Claim: default/pvc-mysql
Cause

pvc-mysql 생성 시 namespace 필드를 누락하여 PVC가 의도와 다르게 default namespace에 생성됨.

이 상태에서 Static PV(pv-mysql-nfs)가 해당 PVC와 먼저 바인딩되었고, 이후 올바른 namespace(mini-cloud)에 생성한 PVC는 PV와 바인딩할 수 없게 되었다.

중요한 개념:

PVC는 namespace scoped resource

PV는 cluster scoped resource

따라서 동일한 이름의 PVC라도 namespace가 다르면 서로 다른 객체이며, PV는 한 번 바인딩되면 다른 PVC에 재사용될 수 없다.

Resolution

잘못 생성된 PVC와 PV를 삭제한 후 올바른 namespace로 다시 생성하였다.

kubectl delete pvc pvc-mysql -n default
kubectl delete pv pv-mysql-nfs

이후 PVC manifest에 namespace를 명시하여 재생성:

metadata:
  name: pvc-mysql
  namespace: mini-cloud

PV와 PVC를 다시 생성한 후 정상적으로 바인딩됨.

확인:

kubectl get pv,pvc -A -o wide
Lesson Learned

Static PV 환경에서는 PVC namespace를 반드시 명시해야 한다.

PV는 cluster resource이므로 잘못된 PVC에 바인딩될 수 있다.

kubectl get pv,pvc -A 명령으로 바인딩 상태를 항상 확인하는 것이 중요하다.

2. NFS root_squash Permission Issue
Symptom

WordPress 및 MySQL Pod가 CrashLoopBackOff 상태로 반복 재시작됨.

로그 확인 시 다음과 같은 오류 발생:

chown: changing ownership of '/var/lib/mysql': Operation not permitted

또는 WordPress 초기화 단계에서 파일 권한 오류 발생.

Cause

NFS 서버 export 설정에서 root_squash 정책이 적용되어 있었기 때문이다.

root_squash는 NFS 클라이언트의 root 사용자를 서버 측에서 nobody 사용자로 매핑하여 권한 상승을 방지하는 보안 기능이다.

그러나 MySQL과 WordPress 컨테이너는 초기화 과정에서 데이터 디렉터리의 ownership을 변경(chown)하려고 시도하며, 이 작업이 NFS 서버에서 거부되면서 컨테이너 초기화가 실패하였다.

Resolution

NFS export 설정에 no_root_squash 옵션을 추가하여 컨테이너 root 사용자가 파일 ownership을 변경할 수 있도록 허용하였다.

NFS 서버 /etc/exports 수정:

/srv/nfs/mysql      10.10.8.0/24(rw,sync,no_subtree_check,no_root_squash)
/srv/nfs/wordpress  10.10.8.0/24(rw,sync,no_subtree_check,no_root_squash)

설정 적용:

sudo exportfs -rav
sudo systemctl restart nfs-kernel-server

이후 Pod를 재생성하여 정상적으로 초기화가 완료되었다.

kubectl delete pod -l app=mysql -n mini-cloud
kubectl delete pod -l app=wordpress -n mini-cloud
Lesson Learned

Stateful workload (MySQL, WordPress 등)은 초기화 과정에서 chown을 수행하는 경우가 많다.

NFS root_squash 정책은 이러한 작업을 차단할 수 있다.

단순한 파일 write 테스트로는 NFS 권한 문제를 완전히 검증할 수 없다.

데이터베이스나 애플리케이션 스토리지를 NFS에 사용할 때는 export 옵션을 반드시 확인해야 한다.