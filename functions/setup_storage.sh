#!/bin/bash

# Fonction pour créer les stockages LVM et la configuration Cloud-init
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

        echo "Stockage $storage créé avec succès."
    done

    # Après la boucle : création du volume pour Cloud-init
    echo "Configuration de Cloud-init et du volume snippets..."

    # Volume pour Cloud-init (snippets)
    storage="local"  # Assurez-vous que 'local' est bien défini dans votre configuration.
    lvcreate -n cloud_init -L 10G "$storage"

    # Formatage du volume
    mkfs.ext4 /dev/$storage/cloud_init

    # Création du point de montage
    mount /dev/$storage/cloud_init /mnt

    # Création du répertoire 'snippets' pour Cloud-init
    mkdir -p /mnt/snippets

    # Ajouter cette partition au fichier /etc/fstab pour un montage automatique
    echo "/dev/$storage/cloud_init /mnt ext4 defaults 0 0" >> /etc/fstab

    echo "Volume Cloud-init créé et répertoire 'snippets' configuré."

    echo "Redémarrage des services..."
    # Redémarrage des services Proxmox
    systemctl restart pvedaemon
    systemctl restart pveproxy
}
