#!/bin/bash

# Désactivation des dépôts d'entreprise et ajout des dépôts communautaires
setup_repositories() {

    echo "Création des groupes de ressources..."
    for pool in pare-feu zone-relais zone-exposee service-interne template testing; do
        pveum pool add $pool || { echo "Erreur de création du groupe $pool"; exit 1; }
    done
    
    echo "Groupes de ressources créés avec succès."
    
    # Suppression des fichiers de dépôt d'entreprise Proxmox
    echo "Suppression des fichiers de dépôt d'entreprise Proxmox..."
    rm -f /etc/apt/sources.list.d/pve-enterprise.list
    # Ne pas supprimer ceph-quincy.list si vous souhaitez conserver Ceph
    # rm -f /etc/apt/sources.list.d/ceph-quincy.list (ne pas supprimer)

    # Nettoyage des références problématiques
    echo "Nettoyage des références problématiques..."
    sed -i '/enterprise.proxmox.com/d' /etc/apt/sources.list
    # Ne pas supprimer les références Ceph
    # sed -i '/ceph-quincy/d' /etc/apt/sources.list.d/*.list (ne pas supprimer)

    # Activation des dépôts non commerciaux de Proxmox
    echo "Activation des dépôts non commerciaux de Proxmox..."
    echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list

    # Ajouter les dépôts de sécurité Debian si nécessaire
    echo "Ajout du dépôt de sécurité Debian..."
    echo "deb http://security.debian.org/debian-security bookworm-security main" | tee -a /etc/apt/sources.list

    # Ajouter le dépôt HashiCorp pour Terraform
    echo "Ajout du dépôt HashiCorp..."
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

    # Mise à jour des dépôts
    echo "Mise à jour des dépôts..."
    apt clean
    apt update
}
