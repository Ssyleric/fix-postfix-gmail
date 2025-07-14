#!/bin/bash

# === CONFIGURATION ===
GMAIL_USER="xxxxxxxx@gmail.com"
GMAIL_PASS="VOTRE_MOT_DE_PASSE_APPLICATION"
RELAY="[smtp.gmail.com]:587"
MAILNAME_DOMAIN="gmail.com"
DISCORD_WEBHOOK="https://discord.com/api/webhooks/XXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX"
LOGFILE="/var/log/fix-postfix-gmail.log"

# === LOGGER ===
log() {
  echo -e "[$(date +"%Y-%m-%d %H:%M:%S")] $1" | tee -a "$LOGFILE"
}

# === DISCORD ENVOI ===
send_discord_report() {
  [ -z "$DISCORD_WEBHOOK" ] && return
  curl -s -X POST \
    -H "Content-Type: multipart/form-data" \
    -F "payload_json={\"content\": \"Configuration Postfix Gmail terminée. Voir log.\"}" \
    -F "file=@$LOGFILE;type=text/plain" \
    "$DISCORD_WEBHOOK" > /dev/null
}

# === INSTALLATION PAQUETS REQUIS ===
log "[1/7] Vérification des paquets requis..."
apt-get update -qq
for pkg in mailutils postfix libsasl2-modules; do
  dpkg -s "$pkg" &> /dev/null || apt-get install -y "$pkg"
done

# === MAILNAME ===
log "[2/7] Configuration de /etc/mailname..."
echo "$MAILNAME_DOMAIN" > /etc/mailname

# === SASL_PASSWD ===
log "[3/7] Configuration de sasl_passwd..."
SASL_FILE="/etc/postfix/sasl_passwd"
echo "$RELAY $GMAIL_USER:$GMAIL_PASS" > "$SASL_FILE"
chmod 600 "$SASL_FILE"
postmap hash:"$SASL_FILE"

# === /etc/postfix/generic ===
log "[4/7] Configuration de /etc/postfix/generic..."
GENERIC_FILE="/etc/postfix/generic"
if ! grep -q "$GMAIL_USER" "$GENERIC_FILE" 2>/dev/null; then
  echo "root@$(hostname -f) $GMAIL_USER" > "$GENERIC_FILE"
  postmap hash:"$GENERIC_FILE"
  chmod 600 "$GENERIC_FILE" "$GENERIC_FILE.db"
fi

# === main.cf ===
log "[5/7] Mise à jour de main.cf..."
postconf -e "relayhost = $RELAY"
postconf -e "smtp_use_tls = yes"
postconf -e "smtp_tls_security_level = encrypt"
postconf -e "smtp_sasl_auth_enable = yes"
postconf -e "smtp_sasl_password_maps = hash:$SASL_FILE"
postconf -e "smtp_sasl_security_options = noanonymous"
postconf -e "smtp_generic_maps = hash:$GENERIC_FILE"

# === REDEMARRAGE POSTFIX ===
log "[6/7] Redémarrage de Postfix..."
systemctl restart postfix

# === TEST ENVOI ===
log "[7/7] Envoi du mail de test..."
echo "Test automatique Postfix Gmail OK." | mail -s "Postfix OK $(date)" "$GMAIL_USER"

# === DISCORD ===
send_discord_report

log "✅ Script terminé."
exit 0
