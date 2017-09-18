#!/bin/bash
function disable_firewall(){
echo -e "Stopping\n and Disabling Firewall service"
systemctl disable firewalld.service
systemctl stop firewalld.service
}
function disable_selinux(){
echo -e "Disabling \n SELINUX "
sed -i 's/SELINUX=enforcing/  SELINUX=permissive/g' /etc/sysconfig/selinux 
}
function update_yum(){
yum  -y update
}
function add_multipleNic(){
echo -e "Taking\n backup of /etc/udev/rules.d/70-persistent-ipoib.rules"
cp -Pr /etc/udev/rules.d/70-persistent-ipoib.rules  /etc/udev/rules.d/70-persistent-ipoib.rules_bak
cat >> /etc/udev/rules.d/70-persistent-ipoib.rules <<EOF
SUBSYSTEM=="net",ACTION=="add",DRIVERS=="?*",ATTR{address}=="08:00:27:6a:c3:2c",ATTR{dev_id}=="0x0",ATTR{type}=="1",KERNEL=="eth*",NAME="eth10"
SUBSYSTEM=="net",ACTION=="add",DRIVERS=="?*",ATTR{address}=="08:00:27:6a:c3:2d>",ATTR{dev_id}=="0x0",ATTR{type}=="1",KERNEL=="eth*",NAME="eth20"
SUBSYSTEM=="net",ACTION=="add",DRIVERS=="?*",ATTR{address}=="08:00:27:6a:c3:2e>",ATTR{dev_id}=="0x0",ATTR{type}=="1",KERNEL=="eth*",NAME="eth30"
SUBSYSTEM=="net",ACTION=="add",DRIVERS=="?*",ATTR{address}=="08:00:27:6a:c3:2g>",ATTR{dev_id}=="0x0",ATTR{type}=="1",KERNEL=="eth*",NAME="eth40"
EOF
}

function create_nic(){
echo -e "Creating\n Multiple NIC "
cp -Pr /etc/sysconfig/network-scripts/ifcfg-enp0s3 ifcfg-eth10
cp -Pr /etc/sysconfig/network-scripts/ifcfg-enp0s3 ifcfg-eth11
cp -Pr /etc/sysconfig/network-scripts/ifcfg-enp0s3 ifcfg-eth12
cp -Pr /etc/sysconfig/network-scripts/ifcfg-enp0s3 ifcfg-eth13
}

function update_NicInterface(){
echo -e "Updating \n ethernet 0  interfaces controller node"
cat > /etc/sysconfig/network-scripts/ifcfg-eth10 <<EOF
HWADDR="0"i0
DEVICE="eth10"
NM_CONTROLLED="no"
ONBOOT="yes"
BOOTPROTO=static
NAME="eth10"
IPADDR=172.16.100.10
NETMASK=255.255.255.0

EOF


echo -e "Updating\n ethernet 1 interfaces compute node"
cat > /etc/sysconfig/network-scripts/ifcfg-eth20 <<EOF
HWADDR="08:00:27:6a:c3:2d"
DEVICE="eth11"
NM_CONTROLLED="no"
ONBOOT="yes"
BOOTPROTO=static
NAME="eth20"
IPADDR=172.16.100.20
NETMASK=255.255.255.0

EOF

echo -e "Updating\n ethernet 2 interfaces block"
cat > /etc/sysconfig/network-scripts/ifcfg-eth30 <<EOF
HWADDR="08:00:27:6a:c3:2e"
DEVICE="eth13"
NM_CONTROLLED="no"
ONBOOT="yes"
BOOTPROTO=static
NAME="eth30"
IPADDR=172.16.100.30
NETMASK=255.255.255.0

EOF

echo -e "Updating\n ethernet 2 interfaces object"
cat > /etc/sysconfig/network-scripts/ifcfg-eth40 <<EOF
HWADDR="08:00:27:6a:c3:2g"
DEVICE="eth40"
NM_CONTROLLED="no"
ONBOOT="yes"
BOOTPROTO=static
NAME="eth40"
IPADDR=172.16.100.40
NETMASK=255.255.255.0

EOF
}


function restart_network(){
systemctl restart network
ip addr
}

function update_host(){
echo -e "Updating\n /etc/hosts file with all node entry"
cat >> /etc/hosts <<EOF
172.16.100.10 controller controller.openstack.sdahal
172.16.100.20 compute compute.openstack.sdahal
172.16.100.30 block block.openstack.sdahal
172.16.100.40 object object.openstack.sdahal
EOF	
}

function update_ntpd(){
echo -e "Update\n the “Chrony” (NTP Server) configuration to allow connections from our other nodes"
cat >> /etc/chrony.conf <<EOF
Allow 172.16.100.0/24
EOF
echo -e "Restarting\n the chrony service"
systemctl restart chronyd.service
}


function install_openstack(){
echo -e "Enable\n the OpenStack-Liberty yum repository"
yum -y install centos-release-openstack-liberty-1-4.el7.noarch.rpm
echo -e "Install\n the OpenStack client and SELINUX support"
yum -y install python-openstackclient openstack-selinux
}
echo $(disable_firewall)
echo $(disable_selinux)
echo $(update_yum)
echo $(add_multipleNic)
echo $(create_nic)
echo $(update_NicInterface)
echo $(restart_network)
echo $(update_host)
echo $(update_ntpd)
echo $(install_openstack)













