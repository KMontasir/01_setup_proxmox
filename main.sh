#!/bin/bash

# Charger les autres fichiers
source ./variables.sh
source ./functions/setup_storage.sh
source ./functions/setup_repositories.sh
source ./functions/setup_openvswitch.sh
source ./functions/setup_appliance.sh
source ./functions/setup_users.sh

# Fonction principale
main() {
    echo "Début de la configuration..."
    create_lvm
    setup_repositories
    setup_appliance
    setup_openvswitch
    setup_users
    echo "Configuration terminée avec succès !"
}

# Appel de la fonction principale
main
