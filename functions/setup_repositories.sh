#!/bin/bash

# Désactivation des dépôts d'entreprise et ajout des dépôts communautaires
setup_repositories() {
    echo "Création des groupes de ressources..."
    for pool in pare-feu zone-relais zone-exposee service-interne template testing; do
        pveum pool add $pool || { echo "Erreur de création du groupe $pool"; exit 1; }
    done
    
    echo "Groupes de ressources créés avec succès."
    
    echo "Suppression des fichiers de dépôt d'entreprise Proxmox..."
    rm -f /etc/apt/sources.list.d/pve-enterprise.list
    
    echo "Nettoyage des références problématiques..."
    sed -i '/enterprise.proxmox.com/d' /etc/apt/sources.list
    
    echo "Activation des dépôts non commerciaux de Proxmox..."
    echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list

    echo "Mise à jour des dépôts..."
    apt clean
    apt update
}
