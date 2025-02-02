#!/bin/bash

# Fonction pour installer et configurer OpenSSH, Cloud-Init, Terraform
setup_appliance() {
    # Installer et configurer OpenSSH
    echo "Installation et configuration d'OpenSSH..."
    if ! dpkg -l | grep -q openssh-server; then
        apt install openssh-server -y || { echo "Erreur d'installation d'OpenSSH"; exit 1; }
    fi
    sed -i 's/^#Port 22/Port 2222/' /etc/ssh/sshd_config
    sed -i 's/^PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/^#AuthorizedKeysFile .ssh/authorized_keys .ssh/authorized_keys2/AuthorizedKeysFile .ssh/authorized_keys .ssh/authorized_keys2/' /etc/ssh/sshd_config
    
    systemctl restart sshd || { echo "Erreur de redémarrage SSH"; exit 1; }
    echo "OpenSSH configuré avec succès."

    # Installer et configurer Cloud-Init
    echo "Installation de Cloud-Init..."
    if ! dpkg -l | grep -q cloud-init; then
        apt install cloud-init -y || { echo "Erreur d'installation de Cloud-Init"; exit 1; }
    fi
    systemctl enable cloud-init
    systemctl start cloud-init || { echo "Erreur de démarrage de Cloud-Init"; exit 1; }
    echo "Cloud-Init installé et activé."

    # Installer et configurer Open vSwitch
    echo "Installation d'Open vSwitch..."
    if ! dpkg -l | grep -q openvswitch-switch; then
        apt update && apt install -y openvswitch-switch
    fi
    systemctl enable openvswitch-switch
    systemctl start openvswitch-switch || { echo "Erreur de démarrage du service Open vSwitch"; exit 1; }

    # Installer Terraform
    echo "Installation de Terraform..."
    if ! dpkg -l | grep -q terraform; then
        apt-get update && apt-get install -y gnupg software-properties-common curl || { echo "Erreur lors de l'installation des dépendances"; exit 1; }
        apt-get install terraform -y || { echo "Erreur d'installation de Terraform"; exit 1; }
    fi
    echo "Terraform installé avec succès."
}
