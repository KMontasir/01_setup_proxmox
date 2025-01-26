#!/bin/bash

# Fonction pour installer et configurer OpenSSH, Open vSwitch
setup_appliance() {
    # Installer et configurer OpenSSH
    echo "Installation et configuration d'OpenSSH'..."
    apt install openssh-server -y
    sed -i 's/^#Port 22/Port 2222/' /etc/ssh/sshd_config
    sed -i 's/^PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/^#AuthorizedKeysFile .*/AuthorizedKeysFile     .ssh/authorized_keys .ssh/authorized_keys2/' /etc/ssh/sshd_config
    sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    systemctl restart sshd
    echo "OpenSSH configuré avec succès."
}
