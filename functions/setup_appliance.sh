#!/bin/bash

# Fonction pour installer et configurer OpenSSH, Open vSwitch, Cloud-Init et Terraform
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

    # Installer Terraform
    echo "Installation de Terraform..."
    if ! dpkg -l | grep -q terraform; then
        apt-get update && apt-get install -y gnupg software-properties-common curl || { echo "Erreur lors de l'installation des dépendances"; exit 1; }
        wget -O- https://apt.releases.hashicorp.com/gpg | \
        gpg --dearmor | \
        tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

        echo "Vérification de l'empreinte de la clé GPG..."
        gpg --no-default-keyring \
        --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
        --fingerprint || { echo "Erreur de vérification de l'empreinte de la clé"; exit 1; }

        echo "Ajout du dépôt officiel HashiCorp..."
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
        https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
        tee /etc/apt/sources.list.d/hashicorp.list

        apt-get update
        apt-get install terraform -y || { echo "Erreur d'installation de Terraform"; exit 1; }
    fi
    echo "Terraform installé avec succès."

    echo "Création des groupes de ressources..."
    for pool in pare-feu zone-relais zone-exposee service-interne template testing; do
        pveum pool add $pool || { echo "Erreur de création du groupe $pool"; exit 1; }
    done
    echo "Groupes de ressources créés avec succès."
}

# Appel de la fonction pour démarrer le processus
setup_appliance
