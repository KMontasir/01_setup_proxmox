#!/bin/bash

# Fonction pour créer les VMs avec configuration matérielle complète
create_vms() {
    VM_STORAGE="local-lvm-template"

    echo "Création des groupes de ressources..."
    for pool in pare-Feu zone-relais zone-exposee service-interne template testing; do
        pveum pool add $pool
    done

    # Créez un volume LVM pour la VM Firewall
    echo "Création du volume LVM pour Firewall..."
    lvcreate --thinpool $VM_STORAGE/thinpool --virtualsize 16G -n vm-9999-disk-0

    echo "Création de la VM Firewall..."
    qm create 9999 \
        --name "Firewall" \
        --memory 2048 \
        --cores 2 \
        --net0 "virtio,bridge=vmbr0" \
        --net1 "virtio,bridge=vmbr1" \
        --cdrom $OPNSENSE_ISO \
        --boot c \
        --bootdisk scsi0 \
        --scsi0 $VM_STORAGE:vm-9999-disk-0 \
        --pool template

    # Créez un volume LVM pour le serveur Web
    echo "Création du volume LVM pour WebServerTemplate..."
    lvcreate --thinpool $VM_STORAGE/thinpool --virtualsize 32G -n vm-9001-disk-0

    echo "Création du serveur web template..."
    qm create 9001 \
        --name "WebServerTemplate" \
        --memory 2048 \
        --cores 2 \
        --net0 "virtio,bridge=vmbr1,tag=20" \
        --cdrom $LINUX_ISO \
        --boot c \
        --bootdisk scsi0 \
        --scsi0 $VM_STORAGE:vm-9001-disk-0 \
        --pool template

    echo "Démarrage des VMs..."
    #for vm in 9999 8999 9001; do
    #    qm start $vm
    #done
}
