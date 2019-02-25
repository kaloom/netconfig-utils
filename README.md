INTRODUCTION
============

This repo is meant to build a docker image based on Alpine Linux that can be used for network configurations via environment variables

Environment variables supported
-------------------------------

For ipv4
--------

To set an ipv4 address on an interface, the following environment variables must be present:

NET_IFNAME
NET_IPV4_ADDRESS
NET_IPV4_NETMASK

Optionally routes can be added if the following were present:

NET_IPV4_DEST_PREFIX
NET_IPV4_GATEWAY

If NET_SEND_GRATUITOUS_ARP is set to a number, an unsolicated gratuitious arp packets will be sent over the interface once it get configured (number of packets to be sent is from the env. variable)

For ipv6
--------

To set an ipv6 address on an interface, the following environment variables must be present:

NET_IFNAME
NET_IPV6_ADDRESS
NET_IPV6_NETMASK

Optionally routes can be added if the following were present:

NET_IPV6_DEST_PREFIX
NET_IPV6_GATEWAY

Example:
--------
```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: app1
  namespace: default
spec:
  replicas: 1
  template:
    metadata:
      annotations:
        networks: '[ { "name": "green" }, { "name": "blue" } ]'
      labels:
        app: app1
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
                - key: app
                  operator: In
                  values:
                  - app2
            topologyKey: "kubernetes.io/hostname"
      initContainers:
        - name: net-setup-net1
          image: kmabda/alpine:3.9
          env:
            - name: NET_IFNAME
              value: "net9f27410725ab" # green net
            - name: NET_IPV4_ADDRESS
              value: "192.168.42.10"
            - name: NET_IPV4_NETMASK
              value: "24"
            - name: "NET_SEND_GRATUITOUS_ARP"
              value: "3"
            - name: NET_IPV6_ADDRESS
              value: "fd10:42::1"
            - name: NET_IPV6_NETMASK
              value: "64"
          command:
            - "/opt/kaloom/bin/config-network.sh"
          securityContext:
            capabilities:
              add:
                - NET_ADMIN
        - name: net-setup-net2
          image: kmabda/alpine:3.9
          env:
            - name: NET_IFNAME
              value: "net48d6215903df" # blue net
            - name: NET_IPV4_ADDRESS
              value: "192.168.43.10"
            - name: NET_IPV4_NETMASK
              value: "24"
            - name: "NET_SEND_GRATUITOUS_ARP"
              value: "3"
            - name: NET_IPV6_ADDRESS
              value: "fd10:43::1"
            - name: NET_IPV6_NETMASK
              value: "64"
          command:
            - "/opt/kaloom/bin/config-network.sh"
          securityContext:
            capabilities:
              add:
                - NET_ADMIN
      containers:
      - name: alpine-container
        image: kmabda/alpine:3.9
        imagePullPolicy: IfNotPresent
        args:
        - top
```
