#!/bin/bash

# Installation et configuration d'Open vSwitch
setup_openvswitch() {
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
iface vmbr0 inet static
    address $WAN_IP
    netmask $WAN_NETMASK
    gateway $WAN_GATEWAY
    ovs_type OVSBridge
    ovs_ports bond0

# Bridge pour eno4 (vmbr4)
auto vmbr4
iface vmbr4 inet static
    address $LAN_IP
    netmask $LAN_NETMASK
    ovs_type OVSBridge
    ovs_ports $ADMIN_INTERFACE

# Bridge pour VLANs 5, 10 et 20 sur eno3 (vmbr3)
auto vmbr3
iface vmbr3 inet manual
    ovs_type OVSBridge
    ovs_ports $LAN_INTERFACE vlan5 vlan10 vlan20

# VLAN 5 sur vmbr3
auto vlan5
iface vlan5 inet manual
    ovs_type OVSIntPort
    ovs_bridge vmbr3
    ovs_options tag=5

# VLAN 10 sur vmbr3
auto vlan10
iface vlan10 inet manual
    ovs_type OVSIntPort
    ovs_bridge vmbr3
    ovs_options tag=10

# VLAN 20 sur vmbr3
auto vlan20
iface vlan20 inet manual
    ovs_type OVSIntPort
    ovs_bridge vmbr3
    ovs_options tag=20

# Bridge pour VLANs 30 et 40 (vmbr2)
auto vmbr2
iface vmbr2 inet manual
    ovs_type OVSBridge
    ovs_ports vlan30 vlan40

# VLAN 30 sur vmbr2
auto vlan30
iface vlan30 inet manual
    ovs_type OVSIntPort
    ovs_bridge vmbr2
    ovs_options tag=30

# VLAN 40 sur vmbr2
auto vlan40
iface vlan40 inet manual
    ovs_type OVSIntPort
    ovs_bridge vmbr2
    ovs_options tag=40

# Bridge pour VLANs 50 et 60 (vmbr1)
auto vmbr1
iface vmbr1 inet manual
    ovs_type OVSBridge
    ovs_ports vlan50 vlan60

# VLAN 50 sur vmbr1
auto vlan50
iface vlan50 inet manual
    ovs_type OVSIntPort
    ovs_bridge vmbr1
    ovs_options tag=50

# VLAN 60 sur vmbr1
auto vlan60
iface vlan60 inet manual
    ovs_type OVSIntPort
    ovs_bridge vmbr1
    ovs_options tag=60
EOF

    echo "Mise à jour du fichier /etc/hosts..."
    # Sauvegarde du fichier /etc/hosts
    cp $HOSTS_FILE ${HOSTS_FILE}.backup.$(date +%Y%m%d%H%M%S)

    # Ajout des entrées WAN et LAN
    sed -i "/$WAN_IP/d" $HOSTS_FILE
    sed -i "/$LAN_IP/d" $HOSTS_FILE
    cat <<EOF >> $HOSTS_FILE

# Proxmox Management Interfaces
$WAN_IP    $HOSTNAME.$WAN_DOMAIN $HOSTNAME
$LAN_IP    $HOSTNAME.$LAN_DOMAIN $HOSTNAME
EOF

    echo "Redémarrage des services réseau... 1/2"
    systemctl restart openvswitch-switch
    systemctl restart networking

    echo "Ajout des interfaces aux bridges OVS"
    ovs-vsctl add-port vmbr0 bond0
    ovs-vsctl add-port vmbr4 $ADMIN_INTERFACE
    ovs-vsctl add-port vmbr3 $LAN_INTERFACE

    echo "Redémarrage des services réseau... 2/2"
    systemctl restart openvswitch-switch
    systemctl restart networking

    echo "Configuration Open vSwitch terminée."
    echo "Vérifiez la configuration avec 'ovs-vsctl show' et 'ip a'."
}
