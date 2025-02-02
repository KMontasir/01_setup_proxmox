#!/bin/bash

# Fonction pour configurer les dépôts
setup_repositories() {
    echo "Création des groupes de ressources..."
    for pool in pare-feu zone-relais zone-exposee service-interne template testing; do
        pveum pool add $pool || { echo "Erreur de création du groupe $pool"; exit 1; }
    done
    
    echo "Groupes de ressources créés avec succès."
    
    # Suppression des fichiers de dépôt d'entreprise Proxmox et ceph-quincy
    echo "Suppression des fichiers de dépôt d'entreprise Proxmox et de ceph-quincy..."
    rm -f /etc/apt/sources.list.d/pve-enterprise.list
    rm -f /etc/apt/sources.list.d/ceph-quincy.list
    
    # Nettoyage des références problématiques pour Proxmox et Ceph
    echo "Nettoyage des références problématiques..."
    sed -i '/enterprise.proxmox.com/d' /etc/apt/sources.list
    sed -i '/ceph-quincy/d' /etc/apt/sources.list.d/*.list
    
    # Activation des dépôts non commerciaux de Proxmox
    echo "Activation des dépôts non commerciaux de Proxmox..."
    echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list
    
    # Mise à jour des dépôts
    echo "Mise à jour des dépôts..."
    apt clean -y
    apt update -y
    apt upgrade -y
    apt autoremove -y

    # Ajouter le dépôt HashiCorp pour Terraform
    echo "Ajout du dépôt HashiCorp..."
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
    gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
    apt update -y
}
