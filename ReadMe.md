# Solarflare Device Plugin
---------------------------
https://asciinema.org/a/UyzMDcSHB42eWrP0soiwPyhEM

### Steps to deploy
    $ git clone this repo
    $ cd sfc-device-plugin
    $ docker build -t sfc-dev-plugin .
 Adjust the config map parameters for onload configuration:

    $ cat device_plugins/sfc_nic/device_plugin.yml
    ---
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: configmap
    data:
      onload-version: 201606-u1.3
      reg-exp-sfc: (?m)[\r\n]+^.*SFC[6-9].*$
      socket-name: sfcNIC
      resource-name: solarflare/smartNIC
      k8s-api: http://<master-ip>:8080
      node-label-onload-version: device.sfc.onload-version
  And then deploy the daemonsets:

    $ kubectl apply -f device_plugins/sfc_nic/device-plugin.yml -n kube-system


### Verify if NICs got picked up by plugin and reported fine to kubelet

    [root@dell-r620-01 kubernetes]# kubectl get nodes -o json | jq     '.items[0].status.capacity'
    {
    "cpu": "16",
    "memory": "131816568Ki",
    "solarflare/smartNIC": "2",
    "pods": "110"
    }

### sample pod template to consume SFC NICs
    apiVersion: v1
    kind: Pod
    metadata:
      name: my.pod1
      annotations:
        sfc-nic-ip: 70.70.70.1/24
    spec:
        containers:
        - name: demo1
        image: sfc-dev-plugin:latest
        imagePullPolicy: Never
        resources:
            requests:
                solarflare/smartNIC: '1'
            limits:
                solarflare/smartNIC: '1'

### More Details:
    https://docs.google.com/document/d/18lX8aqoQhB8vBlupo0nfxgh-49EeMU8bTlHioFjEg-c/edit#heading=h.6ef835v63927
