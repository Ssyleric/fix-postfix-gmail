# README — fix-postfix-gmail.sh

## 📌 Objectif

Configurer automatiquement Postfix pour envoyer des emails via Gmail (SMTP) sur un serveur Linux.

## 📂 Emplacement recommandé

`/home/scripts/fix-postfix-gmail.sh`

## ✅ Fonctionnalités

* Vérifie la présence des paquets requis : `postfix`, `mailutils`, `libsasl2-modules`
* Crée et protège `/etc/postfix/sasl_passwd` avec mot de passe d'application Gmail
* Gère le mapping d'adresse `root@<host>` vers Gmail via `/etc/postfix/generic`
* Modifie intelligemment `/etc/postfix/main.cf` sans écraser les valeurs existantes
* Redémarre le service `postfix`
* Envoie un mail de test à l'adresse Gmail
* Envoie un rapport avec log vers un webhook Discord

## 🔐 Sécurité

Le mot de passe d'application Gmail est stocké dans `/etc/postfix/sasl_passwd` avec des permissions `600`. Le script utilise `postmap` pour générer le fichier `.db` requis.

**🔒 Important** : Les adresses email et mots de passe doivent être remplacés dans le script par des variables ou laissés vides avant publication publique (ex : GitHub).

## 🛠️ Dépendances

* `postfix`
* `mailutils`
* `libsasl2-modules`
* `curl`

Ces paquets sont automatiquement installés si absents.

## 🧪 Test manuel

```bash
echo "Test manuel" | mail -s "Sujet" xxxxxxxx@gmail.com
tail -n 30 /var/log/mail.log
```

## 📩 Résolution de problèmes

* `No worthy mechs found` → Installer `libsasl2-modules`
* `.db missing` → Lancer `postmap /etc/postfix/sasl_passwd`
* IPv6 inaccessible → Désactiver IPv6 ou forcer IPv4 dans `/etc/postfix/main.cf`

## 📦 Exemple d'exécution

```bash
chmod +x /home/scripts/fix-postfix-gmail.sh
/home/scripts/fix-postfix-gmail.sh
```

## 📡 Intégration Discord

Un rapport (texte + log) est envoyé sur Discord via un webhook si configuré.

## 📆 Dernière mise à jour

14/07/2025

## 👤 Auteur

Ssyleric

---

**Important :** ce script est conçu pour des environnements simples (type Proxmox, Debian, LXC). Pour des serveurs de production avec restrictions réseau ou sécurité avancée, une configuration manuelle et un audit sont recommandés.
