#!/bin/bash


# 1. Kontrollera behörighet (Måste vara root/UID 0)
if [[ $EUID -ne 0 ]]; then
   echo "Fel: Detta script måste köras som root (använd sudo)."
   exit 1
fi

# Kontrollera att minst ett användarnamn skickats med som argument
if [ $# -eq 0 ]; then
    echo "Användning: $0 användare1 användare2 ..."
    exit 1
fi

# Loopa igenom alla argument (användarnamn) som skickats till scriptet
for username in "$@"; do

    # 2. Skapa användaren
    # -m skapar hemkatalogen automatiskt om den inte finns
    if id "$username" &>/dev/null; then
        echo "Användaren '$username' finns redan, hoppar över..."
        continue
    else
        useradd -m "$username"
        echo "Skapade användare: $username"
    fi

    # Definiera sökvägen till användarens hemkatalog
    USER_HOME="/home/$username"

    # 3. Skapa katalogstruktur
    # Skapar Documents, Downloads och Work
    mkdir -p "$USER_HOME/Documents" "$USER_HOME/Downloads" "$USER_HOME/Work"

    # Sätt rättigheter: Endast ägaren får läsa, skriva och köra (700)
    # Vi sätter även ägarskapet så att användaren faktiskt äger sina nya mappar
    chown -R "$username":"$username" "$USER_HOME"
    chmod 700 "$USER_HOME/Documents"
    chmod 700 "$USER_HOME/Downloads"
    chmod 700 "$USER_HOME/Work"
    # Säkerställ att även hemkatalogen är privat
    chmod 700 "$USER_HOME"

    # 4. Skapa välkomstmeddelande (welcome.txt)
    WELCOME_FILE="$USER_HOME/welcome.txt"
    
    # Första raden: Personligt meddelande
    echo "Välkommen $username" > "$WELCOME_FILE"
    
    # Andra delen: Lista alla befintliga användare i systemet
    # Vi hämtar första kolumnen från /etc/passwd
    cut -d: -f1 /etc/passwd >> "$WELCOME_FILE"

    # Sätt rätt ägare även på välkomstfilen
    chown "$username":"$username" "$WELCOME_FILE"

    echo "Färdigställde profil för: $username"
done

