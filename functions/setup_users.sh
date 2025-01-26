#!/bin/bash

# Fonction pour configurer les utilisateurs
setup_users() {
    echo "Création et configuration des utilisateurs..."
    for user in "${!PROXMOX_USERS[@]}"; do
        proxmox_user=${PROXMOX_USERS[$user]}
        useradd -m -s /bin/bash "$user" && echo "$user:$PROXMOX_PASSWORD" | chpasswd
        usermod -aG sudo "$user"
        mkdir /home/$user/.ssh/
        touch /home/$user/.ssh/authorized_keys
        chown -R $user:$user /home/$user/

        pveum user add "$proxmox_user" --password $PVE_PASSWORD
        pveum acl modify / --users "$proxmox_user" --roles Administrator
        pveum user token add "$proxmox_user" mytoken --privsep 1
        echo "Récupérez les informations du token pour $proxmox_user !"
        echo "Appuyez sur Entrer pour continuer..."
        read
    done
    echo "Utilisateurs configurés avec succès."
}
