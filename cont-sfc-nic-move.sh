#!/bin/bash -x
#containerName=${1}
NIC=${1}
K8S_API=${2}

sleep 0.1
eval POD_UID=`cat /var/lib/kubelet/device-plugins/kubelet_internal_checkpoint |  jq --arg NIC "$NIC" '.Entries[] | select(.DeviceIDs[] | contains($NIC)) | .PodUID'`

eval POD_NAME=$(curl $K8S_API/api/v1/pods/ | jq -r --arg POD_UID $POD_UID '.items[].metadata | select(.uid == $POD_UID) | .name')
eval POD_NAMESPACE=$(curl $K8S_API/api/v1/pods/ | jq -r --arg POD_UID $POD_UID '.items[].metadata | select(.uid == $POD_UID) | .namespace')
eval IP=$(curl $K8S_API/api/v1/namespaces/${POD_NAMESPACE}/pods/${POD_NAME} | jq '.metadata.annotations["sfc-nic-ip"]')
containerName="k8s_POD_${POD_NAME}_${POD_NAMESPACE}"

ssh -o StrictHostKeyChecking=no 127.0.0.1 rm -f /var/run/netns/$containerName
#containerID=`docker ps | grep $containerName | awk {'print $1'}`
containerID=`docker -H unix:///gopath/run/docker.sock ps | grep $containerName | awk {'print $1'}`
echo $containerID
while [ -z $containerID ]; do
	echo "sleep"
	containerID=`docker ps | grep $containerName | awk {'print $1'}`
	  sleep 0.1
done
PID=`docker -H unix:///gopath/run/docker.sock inspect --format '{{ .State.Pid }}' $containerID`
if [[ `ssh -o StrictHostKeyChecking=no 127.0.0.1 test ! -d /var/run/netns && ssh -o StrictHostKeyChecking=no 127.0.0.1 ip netns add dummyNS` ]]; then
	echo "netns directory got created!!"
fi
ssh -o StrictHostKeyChecking=no 127.0.0.1 ln -s /proc/$PID/ns/net /var/run/netns/$containerName
ssh -o StrictHostKeyChecking=no 127.0.0.1 ip link set dev $NIC netns $containerName
ssh -o StrictHostKeyChecking=no 127.0.0.1 ip netns exec $containerName ip addr add $IP dev $NIC
ssh -o StrictHostKeyChecking=no 127.0.0.1 ip netns exec $containerName ip link set $NIC up

