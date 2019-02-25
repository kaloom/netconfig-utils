#!/bin/sh

add_ip_address() {
    dev=$1
    ip=$2
    netmask=$3

    ip a add ${ip}/${netmask} dev ${dev}
    ip l set dev ${dev} up
}

add_route() {
    dest_prefix=$1
    gateway=$2
    
    ip r add $dest_prefix via ${gateway}
}

default_gratuitous_arp=5
send_gratuitous_arp() {
    dev=$1
    ip=$2

    count=$default_gratuitous_arp
    if expr $3 + 0 >/dev/null 2>&1 && [ $3 -gt 0 ]; then
	count=${3}
    fi

    arping -U -c $count -I $dev $ip
}

if [ -n "${NET_IFNAME}" ] && [ -n "${NET_IPV4_ADDRESS}" ] && [ -n "${NET_IPV4_NETMASK}" ]; then
    add_ip_address ${NET_IFNAME} ${NET_IPV4_ADDRESS} ${NET_IPV4_NETMASK}
    if [ -n "${NET_SEND_GRATUITOUS_ARP}" ]; then
	send_gratuitous_arp ${NET_IFNAME} ${NET_IPV4_ADDRESS} ${NET_SEND_GRATUITOUS_ARP}
    fi
    added_an_ipv4=1
fi

if [ -n "${NET_IFNAME}" ] && [ -n "${NET_IPV6_ADDRESS}" ] && [ -n "${NET_IPV6_NETMASK}" ]; then
    add_ip_address ${NET_IFNAME} ${NET_IPV6_ADDRESS} ${NET_IPV6_NETMASK}
    added_an_ipv6=1
fi

if [ -n "${NET_IPV4_DEST_PREFIX}" ] && [ -n "${NET_IPV4_GATEWAY}" ]; then
    add_route ${NET_IPV4_DEST_PREFIX} ${NET_IPV4_GATEWAY}
    added_an_ipv4_route=1
fi

if [ -n "${NET_IPV6_DEST_PREFIX}" ] && [ -n "${NET_IPV6_GATEWAY}" ]; then
    add_route ${NET_IPV6_DEST_PREFIX} ${NET_IPV6_GATEWAY}
    added_an_ipv6_route=1
fi


if [ -z "${added_an_ipv4}" ] && [ -z "${added_an_ipv4_route}" ] && [ -z "${added_an_ipv6}" ] && [ -z "${added_an_ipv6_route}" ]; then
    echo "to add an ipv4 address to an interface, environment variables NET_IFNAME, NET_IPV4_ADDRESS and NET_IPV4_NETMASK must be defined"
    echo "to add an ipv6 address to an interface, environment variables NET_IFNAME, NET_IPV6_ADDRESS and NET_IPV6_NETMASK must be defined"
    echo "to add an ipv4 route, environment variables NET_IPV4_DEST_PREFIX and NET_IPV4_GATEWAY must be defined"
    echo "to add an ipv6 route, environment variables NET_IPV6_DEST_PREFIX and NET_IPV6_GATEWAY must be defined"
    exit 1
fi
