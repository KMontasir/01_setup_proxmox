#!/bin/bash

# Fonction pour créer les stockages LVM et gérer Cloud-init
create_lvm() {
    echo "Création des stockages LVM..."

    # Traitement du disque /dev/sdb (pour les VM et Cloud-init)
    echo "Traitement du disque: $DISK1"
    wipefs -a "$DISK1" # Nettoyage du disque /dev/sdb
    
    # Création du groupe de volumes pour les VM et Cloud-init
    vgcreate "$VM_STORAGE_NAME" "$DISK1"

    # Création du volume thin-pool pour les VM
    lvcreate --type thin-pool -l "$VM_SIZE" -n "$THINPOOL_NAME" "$VM_STORAGE_NAME"

    # Ajout de la configuration dans le fichier /etc/pve/storage.cfg
    echo "
lvmthin: $VM_STORAGE_NAME
    vgname $VM_STORAGE_NAME
    thinpool $THINPOOL_NAME
    content rootdir,images" >> /etc/pve/storage.cfg

    echo "Stockage $VM_STORAGE_NAME créé avec succès."

    # Traitement du disque /dev/sdc (pour les PVE)
    echo "Traitement du disque: $DISK2"
    wipefs -a "$DISK2" # Nettoyage du disque /dev/sdc
    
    # Création du groupe de volumes pour les installations de PVE
    vgcreate "$PVE_STORAGE_NAME" "$DISK2"

    # Création des volumes logiques pour chaque PVE (pve1 et pve2)
    lvcreate -n pve1 -L "$PVE1_SIZE" "$PVE_STORAGE_NAME"  # Par exemple, 50 Go pour le premier PVE
    lvcreate -n pve2 -L "$PVE2_SIZE" "$PVE_STORAGE_NAME"  # Par exemple, 50 Go pour le deuxième PVE

    # Ajout des volumes dans la configuration de stockage
    echo "
lvm: $PVE_STORAGE_NAME
    vgname $PVE_STORAGE_NAME
    content rootdir,images" >> /etc/pve/storage.cfg

    echo "Stockage $PVE_STORAGE_NAME créé avec succès."

    # Redémarrage des services une fois que tous les stockages sont créés
    systemctl restart pvedaemon
    systemctl restart pveproxy

    # Modification de la configuration du stockage local pour accepter les snippets
    echo "Modification de la configuration du stockage local pour accepter les snippets..."
    pvesm set local --content images,iso,rootdir,vztmpl,backup,snippets

    # Création du répertoire pour les snippets si nécessaire
    echo "Vérification et création du répertoire $SNIPPETS_DIR..."
    if [ ! -d "$SNIPPETS_DIR" ]; then
        mkdir -p "$SNIPPETS_DIR"
        echo "Répertoire $SNIPPETS_DIR créé."
    else
        echo "Le répertoire $SNIPPETS_DIR existe déjà."
    fi

    pvesm add dir snippets --path "$SNIPPETS_DIR" --content images,iso,snippets

    # Vous pouvez ici ajouter vos fichiers Cloud-init dans ce répertoire si nécessaire
    echo "Ajouter vos fichiers Cloud-init dans $SNIPPETS_DIR."

    echo "La gestion des stockages LVM et Cloud-init a été effectuée avec succès."
}

# Assurez-vous d'utiliser la commande `qm set` pour appliquer les fichiers cloud-init
# Exemple: qm set 100 --cicustom "user=$SNIPPETS_DIR/user-data,network=$SNIPPETS_DIR/network-config,meta=$SNIPPETS_DIR/meta-data"
