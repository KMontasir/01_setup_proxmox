# Proxmox Configuration Scripts

Ce projet regroupe plusieurs scripts Bash modulaires pour configurer un serveur Proxmox. Il permet d'automatiser la configuration des utilisateurs, du stockage, des réseaux (Open vSwitch), et la création de machines virtuelles (VM).

---

## Structure du projet

Le projet est divisé en plusieurs fichiers pour une meilleure modularité et maintenabilité :

- **`main.sh`** : Script principal qui orchestre l'exécution des autres fichiers.
- **`variables.sh`** : Contient toutes les variables globales utilisées dans les scripts.
- **`setup_storage.sh`** : Configure les volumes de stockage LVM.
- **`setup_openvswitch.sh`** : Installe et configure Open vSwitch.
- **`setup_users.sh`** : Crée et configure les utilisateurs pour Proxmox.
- **`create_vms.sh`** : Automatisation de la création des machines virtuelles.

---

## Prérequis

- Un serveur **Proxmox** installé et accessible.
- Les fichiers de script doivent être placés dans le répertoire `/root/` du serveur.
- Les permissions nécessaires pour exécuter des commandes avec `sudo` ou en tant que root.

---

## Installation via

1. **Transférer les fichiers sur le serveur Proxmox :**
   Utilisez `scp` pour copier les fichiers sur le serveur :
   ```bash
   scp *.sh root@<IP-SERVEUR>:/root/

2. **Rendre les scripts exécutables :** 
```bash
chmod +x *.sh
```

3. **Vérifier les variables :**
Ouvrez le fichier `variables.sh` et personnalisez les valeurs selon vos besoins :  
```bash
nano variables.sh
```

## Installation via clé USB

Vous pouvez exécuter les scripts directement depuis une clé USB sur votre serveur Proxmox.

### Étapes pour utiliser la clé USB :
1. **Préparer la clé USB** :
   - Formatez la clé USB avec le système de fichiers `ext4`.
   - Copiez tous les scripts (`*.sh`) sur la clé USB.

2. **Sur le serveur Proxmox** :
   - Vérifier les montages périphériques existants :
     ```bash
     sudo lsblk
     sudo ls /dev/
     ```     
   - Branchez la clé USB.
   - Identifier le nouveau périphérique
     ```bash
     sudo lsblk
     sudo ls /dev/
     ```  
   - Montez la clé USB :
     ```bash
     sudo mount /dev/sdb1 /mnt/usb
     ```

3. **Copier, puis exécuter le script principal** :
   - Accédez à la clé USB et exécutez le script principal :
     ```bash
     sudo cp -R /mnt/usb/install_proxmox/ /root/
     cd /root/install_proxmox/
     ./main.sh
     ```

## Utilisation  

### Exécution complète via alias  
Vous pouvez configurer un alias pour exécuter le script principal `main.sh` directement depuis votre terminal sans avoir à spécifier le chemin du script à chaque fois. Voici comment procéder :

1. Ouvrez votre fichier de configuration du shell (par exemple `~/.bashrc`, `~/.bash_profile`, ou `~/.zshrc` selon le shell que vous utilisez) :
   ```bash
   nano ~/.bashrc  # ou ~/.zshrc pour zsh
   ```

2. Ajoutez l'alias suivant à la fin du fichier :
   ```bash
   alias run_proxmox_config='/root/main.sh'
   ```

   Assurez-vous que le chemin vers `main.sh` est correct.

3. Sauvegardez le fichier et rechargez la configuration du shell :
   ```bash
   source ~/.bashrc  # ou source ~/.zshrc pour zsh
   ```

4. Maintenant, vous pouvez exécuter le script avec simplement la commande suivante :
   ```bash
   run_proxmox_config
   ```

### Exécution sans alias  
Si vous ne souhaitez pas utiliser un alias et préférez exécuter le script directement, lancez simplement la commande suivante :
```bash
./main.sh
```

## Structure des Variables  

Les variables sont définis dans `variables.sh` 
### Utilisateurs  
Les utilisateurs sont définis dans une table associative :  
```bash
declare -A PROXMOX_USERS=(
    ["montasir"]="pveadmin-montasir@pve" 
    ...  
)
```

### Stockage  
Les configurations de stockage sont également définies dans `variables.sh` :  
```bash
declare -A STORAGE_CONFIGS=(  
    ["local-lvm-thin"]="/dev/sdb"  
    ...  
)
```

### VMs  
Les modèles de VMs (taille, ISO, ressources, etc.) sont décrits dans une table associative :  
```bash
declare -A VM_TEMPLATES=(  
    ["Firewall"]="16G /var/lib/vz/template/iso/OPNsense-24.7-dvd-amd64.iso Pare-Feu 2 2048 vmbr0,vmbr1"  
    ...  
)
```

## Personnalisation  

Vous pouvez modifier les configurations en éditant directement le fichier `variables.sh`.  
Assurez-vous que les chemins ISO et les paramètres réseau correspondent à votre environnement Proxmox.  

## Dépannage  

- **Problèmes de permission :**  
Vérifiez que tous les scripts ont les permissions d'exécution (`chmod +x`).  

- **Erreurs lors de la configuration réseau :**  
Assurez-vous que les noms des interfaces réseau dans `setup_openvswitch.sh` correspondent à ceux de votre serveur.  

- **Logs :**  
Vérifiez les logs du système Proxmox pour diagnostiquer les erreurs :  
```bash
journalctl -xe
```

## Licence  

Ce projet est sous licence MIT. Vous êtes libre de le modifier et de l'utiliser à votre convenance.  

## Contributions  

Les contributions sont les bienvenues ! N'hésitez pas à soumettre des issues ou des pull requests pour améliorer le projet.
