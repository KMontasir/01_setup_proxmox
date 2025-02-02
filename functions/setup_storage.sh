# Fonction pour créer les stockages LVM et gérer Cloud-init
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

    # Redémarrage des services une fois que tous les stockages sont créés
    systemctl restart pvedaemon
    systemctl restart pveproxy

    # Création du répertoire pour les snippets si nécessaire
    echo "Vérification et création du répertoire /var/lib/vz/snippets..."
    if [ ! -d "/var/lib/vz/snippets" ]; then
        mkdir -p /var/lib/vz/snippets
        echo "Répertoire /var/lib/vz/snippets créé."
    else
        echo "Le répertoire /var/lib/vz/snippets existe déjà."
    fi

    # Vous pouvez ici ajouter vos fichiers Cloud-init dans ce répertoire si nécessaire
    echo "Ajouter vos fichiers Cloud-init dans /var/lib/vz/snippets."

    echo "La gestion des stockages LVM et Cloud-init a été effectuée avec succès."
}
