#!/bin/bash

# Kontrollera att scriptet körs som root
# Endast root (UID 0) får skapa användare
if [ "$EUID" -ne 0 ]; then
    echo "Fel: Scriptet måste köras som root."
    exit 1
fi

# Kontrollera att minst en användare skickats in
if [ $# -eq 0 ]; then
    echo "Användning: ./create_users.sh användare1 användare2 ..."
    exit 1
fi

# Loopa igenom alla användarnamn som skickas in
for USERNAME in "$@"
do

    # Skapa användaren om den inte redan finns
    if ! id "$USERNAME" &>/dev/null; then
        useradd -m "$USERNAME"
    fi

    HOME_DIR="/home/$USERNAME"

    # Skapa kataloger
    mkdir -p "$HOME_DIR/Documents"
    mkdir -p "$HOME_DIR/Downloads"
    mkdir -p "$HOME_DIR/Work"

    # Sätt ägare
    chown -R "$USERNAME:$USERNAME" "$HOME_DIR/Documents"
    chown -R "$USERNAME:$USERNAME" "$HOME_DIR/Downloads"
    chown -R "$USERNAME:$USERNAME" "$HOME_DIR/Work"

    # Endast ägare får läsa/skriva
    chmod 700 "$HOME_DIR/Documents"
    chmod 700 "$HOME_DIR/Downloads"
    chmod 700 "$HOME_DIR/Work"

    # Skapa välkomstfil
    WELCOME_FILE="$HOME_DIR/welcome.txt"

    echo "Välkommen $USERNAME" > "$WELCOME_FILE"
    echo "" >> "$WELCOME_FILE"
    echo "Användare i systemet:" >> "$WELCOME_FILE"

    # Lista alla användare
    cut -d: -f1 /etc/passwd >> "$WELCOME_FILE"

    # Sätt ägare och rättigheter
    chown "$USERNAME:$USERNAME" "$WELCOME_FILE"
    chmod 700 "$WELCOME_FILE"

done

exit 0
