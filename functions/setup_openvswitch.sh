#!/bin/bash

# Installation et configuration d'Open vSwitch
setup_openvswitch() {
    echo "Installation d'Open vSwitch..."
    apt update && apt install -y openvswitch-switch

    echo "Sauvegarde de la configuration réseau actuelle..."
    cp $CONFIG_FILE ${CONFIG_FILE}.backup.$(date +%Y%m%d%H%M%S)

    echo "Génération de la nouvelle configuration réseau..."

    # Écriture de la configuration réseau
    cat <<EOF > $CONFIG_FILE
# Configuration réseau avec Open vSwitch

# Boucle locale
auto lo
iface lo inet loopback

auto $BOND_INTERFACES_1
iface $BOND_INTERFACES_1 inet manual

auto $BOND_INTERFACES_2
iface $BOND_INTERFACES_2 inet manual

auto $LAN_INTERFACE
iface $LAN_INTERFACE inet manual

auto $ADMIN_INTERFACE
iface $ADMIN_INTERFACE inet manual
    
# Bond0 pour WAN
auto bond0
iface bond0 inet manual
    ovs_bonds $BOND_INTERFACES_1 $BOND_INTERFACES_2
    ovs_type OVSBond
    ovs_bridge vmbr0
    ovs_options bond_mode=active-backup

# Bridge WAN (vmbr0)
auto vmbr0
allow-ovs vmbr0
iface vmbr0 inet static
    address $WAN_IP
    netmask $WAN_NETMASK
    gateway $WAN_GATEWAY
    ovs_type OVSBridge
    ovs_ports bond0

# Bridge pour eno4 (vmbr4)
auto vmbr4
allow-ovs vmbr4
iface vmbr4 inet static
    address $LAN_IP
    netmask $LAN_NETMASK
    ovs_type OVSBridge
    ovs_ports $ADMIN_INTERFACE

# Bridge pour VLANs 5, 10 et 20 sur eno3 (vmbr3)
auto vmbr3
allow-ovs vmbr3
iface vmbr3 inet manual
    ovs_type OVSBridge
    ovs_ports $LAN_INTERFACE

# VLAN 5 sur vmbr3
auto vlan5
allow-vmbr3 vlan5
iface vlan5 inet manual
    ovs_type OVSIntPort
    ovs_tag 5
    ovs_bridge vmbr3

# VLAN 10 sur vmbr3
auto vlan10
allow-vmbr3 vlan10
iface vlan10 inet manual
    ovs_type OVSIntPort
    ovs_tag 10
    ovs_bridge vmbr3

# VLAN 20 sur vmbr3
auto vlan20
allow-vmbr3 vlan20
iface vlan20 inet manual
    ovs_type OVSIntPort
    ovs_tag 20
    ovs_bridge vmbr3

# Bridge pour VLANs 30 et 40 (vmbr2)
auto vmbr2
allow-ovs vmbr2
iface vmbr2 inet manual
    ovs_type OVSBridge

# VLAN 30 sur vmbr2
auto vlan30
allow-vmbr2 vlan30
iface vlan30 inet manual
    ovs_type OVSIntPort
    ovs_tag 30
    ovs_bridge vmbr2

# VLAN 40 sur vmbr2
auto vlan40
allow-vmbr2 vlan40
iface vlan40 inet manual
    ovs_type OVSIntPort
    ovs_tag 40
    ovs_bridge vmbr2

# Bridge pour VLANs 50 et 60 (vmbr1)
auto vmbr1
allow-ovs vmbr1
iface vmbr1 inet manual
    ovs_type OVSBridge

# VLAN 50 sur vmbr1
auto vlan50
allow-vmbr1 vlan50
iface vlan50 inet manual
    ovs_type OVSIntPort
    ovs_tag 50
    ovs_bridge vmbr1

# VLAN 60 sur vmbr1
auto vlan60
allow-vmbr1 vlan60
iface vlan60 inet manual
    ovs_type OVSIntPort
    ovs_tag 60
    ovs_bridge vmbr1
EOF

    echo "Mise à jour du fichier /etc/hosts..."
    # Mise à jour du fichier /etc/hosts
    echo "Sauvegarde de /etc/hosts..."
    cp $HOSTS_FILE ${HOSTS_FILE}.backup.$(date +%Y%m%d%H%M%S)

    # Ajout des entrées WAN et LAN
    sed -i "/$WAN_IP/d" $HOSTS_FILE
    sed -i "/$LAN_IP/d" $HOSTS_FILE
    cat <<EOF >> $HOSTS_FILE

# Proxmox Management Interfaces
$WAN_IP    $WAN_HOSTNAME.$WAN_DOMAIN $WAN_HOSTNAME
$LAN_IP    $LAN_HOSTNAME.$LAN_DOMAIN $LAN_HOSTNAME
EOF

    echo "Redémarrage des services réseau..."
    systemctl restart networking

    echo "Configuration Open vSwitch terminée."
    echo "Vérifiez la configuration avec 'ovs-vsctl show' et 'ip a'."
}
