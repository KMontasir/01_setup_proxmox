#!/bin/bash

# Charger les autres fichiers
source ./variables.sh
source ./functions/setup_storage.sh
source ./functions/setup_repositories.sh
source ./functions/setup_openvswitch
source ./functions/setup_appliance.sh
source ./functions/setup_users.sh
source ./functions/create_vms.sh

# Fonction principale
main() {
    echo "Début de la configuration..."
    create_lvm
    setup_repositories
    setup_openvswitch
    setup_appliance
    setup_users
    #create_vms
    echo "Configuration terminée avec succès !"
}

# Appel de la fonction principale
main
