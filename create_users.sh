#!/bin/bash

# Script: create_users.sh
# Description: Skapar användare, deras katalogstruktur och en välkomstfil.
#              Måste köras som root.

# ---------- 1. Kontrollera att scriptet körs som root ----------
if [[ $EUID -ne 0 ]]; then
    echo "Detta script måste köras som root." >&2
    exit 1
fi

# Kontrollera att minst ett användarnamn har skickats in
if [[ $# -eq 0 ]]; then
    echo "Användning: $0 användare1 [användare2 ...]" >&2
    exit 1
fi

# ---------- Hämta lista över redan existerande "vanliga" användare ----------
# Vi filtrerar på UID >= 1000 och UID < 65534 (undantag för "nobody").
existing_users=()
while IFS=: read -r username _ uid _; do
    if (( uid >= 1000 && uid < 65534 )); then
        existing_users+=("$username")
    fi
done < /etc/passwd

# ---------- Loopa igenom alla angivna användarnamn ----------
for user in "$@"; do
    # Skapa användaren med hemkatalog (-m)
    useradd -m "$user" 2>/dev/null
    if [[ $? -ne 0 ]]; then
        echo "Kunde inte skapa användaren: $user" >&2
        continue
    fi

    homedir="/home/$user"

    # ---------- 3. Skapa undermapparna Documents, Downloads, Work ----------
    # Använd install för att sätta rätt ägare (user:user) och rättigheter (700)
    install -d -m 700 -o "$user" -g "$user" "$homedir/Documents"
    install -d -m 700 -o "$user" -g "$user" "$homedir/Downloads"
    install -d -m 700 -o "$user" -g "$user" "$homedir/Work"

    # ---------- 4. Skapa welcome.txt ----------
    welcomefile="$homedir/welcome.txt"
    echo "Välkommen $user" > "$welcomefile"

    # Skriv ut alla andra befintliga användare (exkludera den nya själv)
    for existing in "${existing_users[@]}"; do
        if [[ "$existing" != "$user" ]]; then
            echo "$existing" >> "$welcomefile"
        fi
    done

    # Ägare och rättigheter för välkomstfilen
    chown "$user":"$user" "$welcomefile"
    chmod 600 "$welcomefile"
done

exit 0
