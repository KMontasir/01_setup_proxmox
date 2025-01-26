#!/bin/bash

# Fonction pour créer les stockages LVM
create_lvm() {
    echo "Création des stockages LVM..."

    # Boucle sur chaque stockage défini dans STORAGE_CONFIGS
    for storage in "${!STORAGE_CONFIGS[@]}"; do
        disk="${STORAGE_CONFIGS[$storage]}"

        echo "Traitement du stockage: $storage ($disk)"

        # Nettoyage du disque
        wipefs -a "$disk"

        # Création du groupe de volumes
        vgcreate "$storage" "$disk"

        # Création du volume thin-pool
        lvcreate --type thin-pool -l 100%FREE -n thinpool "$storage"

        # Ajout de la configuration dans le fichier /etc/pve/storage.cfg
            echo "
lvmthin: $storage
    vgname $storage
    thinpool thinpool
    content rootdir,images" >> /etc/pve/storage.cfg
        fi

        echo "Stockage $storage créé avec succès."
        systemctl restart pvedaemon
        systemctl restart pveproxy
    done
}
