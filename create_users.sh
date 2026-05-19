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

    # --- WELCOME FILE ---
FILE="$HOME_DIR/welcome.txt"

# Första raden (EXAKT format som testet vill ha)
echo "Välkommen $USER" > "$FILE"

# Tom rad
echo "" >> "$FILE"

# Lista andra användare i systemet
echo "Användare:" >> "$FILE"

# Hämtar användare från systemet
cut -d: -f1 /etc/passwd | grep -v "^$USER$" >> "$FILE"

# Sätter rätt ägare
chown "$USER:$USER" "$FILE" 2>/dev/null

# Filen ska bara vara läsbar för ägaren
chmod 600 "$FILE" 2>/dev/null

done

exit 0