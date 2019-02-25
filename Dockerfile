FROM alpine:3.9

# create a directory where we're dropping in our scripts
RUN install -d /opt/kaloom/bin

# copy the network config script to use for configuring the interfaces
# which are not on the main network (eth0), and that uses a cni with a
# null ipam
COPY config-network.sh /opt/kaloom/bin
