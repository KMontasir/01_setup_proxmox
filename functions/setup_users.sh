#!/bin/bash

# Fonction pour configurer les utilisateurs de Proxmox
setup_users() {
    echo "Création et configuration des utilisateurs..."
    for user in "${!PROXMOX_USERS[@]}"; do
        proxmox_user=${PROXMOX_USERS[$user]}
        
        # Création de l'utilisateur Linux
        useradd -m -s /bin/bash "$user"
        usermod -aG sudo "$user"
        mkdir -p /home/$user/.ssh/
        touch /home/$user/.ssh/authorized_keys
        chown -R $user:$user /home/$user/
        chmod 700 /home/$user/.ssh
        chmod 600 /home/$user/.ssh/authorized_keys

        # Création de l'utilisateur Proxmox sans mot de passe
        pveum user add "$proxmox_user" --comment "$user for automation"
        pveum acl modify / --users "$proxmox_user" --roles Administrator

        # Création du token API avec un nom unique
        TOKEN_NAME="${user}_token"
        pveum user token add "$proxmox_user" "$TOKEN_NAME" --privsep 1
        
        echo "Récupérez les informations du token pour $proxmox_user :"
        echo "Utilisateur : $proxmox_user"
        echo "Token Name : $TOKEN_NAME"
        echo "Utilisez 'user@pam!$TOKEN_NAME=<TOKEN_VALUE>' pour l'authentification API."
        echo "Appuyez sur Entrer pour continuer..."
        read
    done
    echo "Utilisateurs configurés avec succès."
}
