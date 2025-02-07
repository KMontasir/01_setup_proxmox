#!/bin/bash

# Créez l'ISO Cloud-Init ici
cloud-init init --config-file=user-data --meta-data=meta-data --output-dir=/tmp/cloud-init-iso

# Fonction pour créer le template avec l'image FreeBSD
create_template() {
    local id=$1
    local name=$2
    local url=$3
    local img_file=$(basename "$url")

    # Vérifier si l'image est compressée en .xz
    if [[ "$img_file" == *.xz ]]; then
        local img_uncompressed="${img_file%.xz}"  # Supprime l'extension .xz
        # Décompresser l'image si nécessaire
        echo "Décompression de l'image..."
        unxz -k "$TEMPLATE_DIR/$name/$img_file"
        img_file="$img_uncompressed"
    fi

    # Création de la VM sans disque
    qm create "$id" --name "$name" --net0 virtio,bridge="$BRIDGE" --scsihw virtio-scsi-single --bios seabios

    # Importer l'image dans le stockage pve_storage_sdb
    qm importdisk "$id" "$TEMPLATE_DIR/$name/$img_file" "$STORAGE_POOL"

    # Lier le disque importé à la VM
    qm set "$id" --scsi0 "${STORAGE_POOL}:vm-${id}-disk-0"

    # Redimensionner le disque
    qm disk resize "$id" scsi0 "$DISK_SIZE"

    # Configurer l'ordre de démarrage
    qm set "$id" --boot order=scsi0 --bios seabios

    # Configuration des ressources de la VM
    qm set "$id" --cpu host --cores "$CORES" --memory "$MEMORY"

    # Ajouter l'ISO Cloud-Init
    qm set "$id" --ide2 "$STORAGE_POOL:/tmp/cloud-init-iso/cloud-init.iso,media=cdrom"

    # Activer l'agent QEMU
    qm set "$id" --agent enabled=1

    # Appliquer la configuration Cloud-Init (en utilisant les fichiers dans le répertoire snippets)
    qm set "$id" --cicustom "user=$SNIPPETS_DIR/user-data,meta=$SNIPPETS_DIR/meta-data"

    # Marquer cette VM comme un template
    qm template "$id"

    # Ajouter la VM au pool "template"
    pvesh set /pools/"$POOL_TEMPLATE" -vms "$id"

    echo "Fin de création du template $name et ajout au pool $POOL_TEMPLATE"
}

# Créer le template avec l'image FreeBSD
create_template 9999 "freebsd-14-cloudinit" "$IMAGE_URL"

echo "Fin de création du paramétrage de base de Proxmox avec le template FreeBSD 14.2"
