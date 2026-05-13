#!/bin/bash

# ==============================================================================
# Script: create_users.sh
# Beskrivning: Automatiserad användarhantering för Linux-prov.
# ==============================================================================

# 1. Kontrollera att användaren är root
if [[ $EUID -ne 0 ]]; then
   echo "Detta script måste köras som root."
   exit 1
fi

# Kontrollera att vi fick argument
if [ $# -eq 0 ]; then
    echo "Användning: $0 namn1 namn2 ..."
    exit 1
fi

# Loopa igenom alla namn som skickades med
for username in "$@"; do

    # 2. Skapa användaren om den inte redan finns
    if id "$username" &>/dev/null; then
        echo "Användaren $username finns redan - uppdaterar bara filer/mappar."
    else
        useradd -m "$username"
        echo "Skapade användare: $username"
    fi

    # Definiera hemkatalogen
    USER_HOME="/home/$username"

    # 3.1 Skapa undermappar
    # Vi skapar dem även om användaren fanns sedan innan
    mkdir -p "$USER_HOME/Documents" "$USER_HOME/Downloads" "$USER_HOME/Work"

    # 3.2 Rättigheter (Endast ägare får läsa/skriva/köra)
    # chmod 700 sätter rwx------
    chown -R "$username":"$username" "$USER_HOME"
    chmod 700 "$USER_HOME"
    chmod 700 "$USER_HOME/Documents"
    chmod 700 "$USER_HOME/Downloads"
    chmod 700 "$USER_HOME/Work"

    # 4. Välkomstfil
    WELCOME_FILE="$USER_HOME/welcome.txt"
    
    # Skriv första raden: Välkommen <användare>
    echo "Välkommen $username" > "$WELCOME_FILE"
    
    # Lista alla ANDRA användare (vi filtrerar bort den aktuella användaren)
    # Vi hämtar alla namn från /etc/passwd men tar bort raden som matchar $username
    cut -d: -f1 /etc/passwd | grep -v "^$username$" >> "$WELCOME_FILE"

    # Sätt ägare på välkomstfilen också
    chown "$username":"$username" "$WELCOME_FILE"
    chmod 600 "$WELCOME_FILE"

    echo "Klar med hantering av $username"
done

echo "Scriptet har körts klart."
