#!/bin/bash -x
version=$1
echo $version
generate_post_data()
{
cat  <<EOF
{
 "metadata": {
    "annotations": {
    "$1": "$2"
    }
 }
}
EOF
}
NODE=$(curl -Gs http://127.0.0.1:10255/pods/ | grep -o '"nodeName":"[^"]*"' | head -n 1|rev | cut -d: -f1 | rev)
NODE=$(eval echo $NODE | tr -d '"')
BASE_URL=$1
KEY=/etc/kubernetes/pki/apiserver-kubelet-client.key
CERT=/etc/kubernetes/pki/apiserver-kubelet-client.crt

/usr/bin/curl --insecure --key $KEY --cert $CERT --request PATCH -H 'Content-Type: application/merge-patch+json' -H 'Accept: application/json' --data "$(generate_post_data $2 $3)" $BASE_URL/api/v1/nodes/$NODE


