#!/bin/bash

# Kollar så scriptet körs som root
if [ "$EUID" -ne 0 ]; then
    echo "Du måste köra som root"
    exit 1
fi

# Loopar igenom alla användare som skickas in
for USER in "$@"
do
    # Hemkatalog för användaren
    HOME_DIR="/home/$USER"

    # Skapar användaren om den inte finns
    if ! id "$USER" &>/dev/null; then
        useradd -m -d "$HOME_DIR" "$USER" 2>/dev/null
    fi

    # Skapar hemkatalog om den saknas
    mkdir -p "$HOME_DIR"

    # Skapar mappar i hemkatalogen
    mkdir -p "$HOME_DIR/Documents"
    mkdir -p "$HOME_DIR/Downloads"
    mkdir -p "$HOME_DIR/Work"

    # Sätter ägare på hela hemkatalogen
    chown -R "$USER:$USER" "$HOME_DIR" 2>/dev/null

    # Sätter rättigheter så bara ägaren har tillgång
    chmod 700 "$HOME_DIR/Documents"
    chmod 700 "$HOME_DIR/Downloads"
    chmod 700 "$HOME_DIR/Work"

    # Skapar welcome.txt
    FILE="$HOME_DIR/welcome.txt"

    # Första raden i filen
    echo "Välkommen $USER" > "$FILE"

    # Tom rad för bättre läsning
    echo "" >> "$FILE"

    # Rubrik för användarlista
    echo "Andra användare i systemet:" >> "$FILE"

    # Hämtar alla användare och tar bort den aktuella
    getent passwd | cut -d: -f1 | grep -v "^$USER$" >> "$FILE"

    # Sätter ägare på welcome.txt
    chown "$USER:$USER" "$FILE" 2>/dev/null

    # Gör filen endast läsbar för ägaren
    chmod 600 "$FILE" 2>/dev/null

done

exit 0