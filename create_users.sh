#!/bin/bash

# =========================
# Kollar att scriptet körs som root
# =========================
if [ "$EUID" -ne 0 ]; then
    echo "Du måste köra som root"
    exit 1
fi

# =========================
# Loopar igenom alla användare som skickas in
# =========================
for USER in "$@"
do
    HOME_DIR="/home/$USER"

    # =========================
    # Skapa användare (om den inte finns)
    # =========================
    if ! id "$USER" &>/dev/null; then
        useradd -m -d "$HOME_DIR" "$USER" 2>/dev/null
    fi

    # =========================
    # Skapa hemkatalog + mappar
    # =========================
    mkdir -p "$HOME_DIR/Documents"
    mkdir -p "$HOME_DIR/Downloads"
    mkdir -p "$HOME_DIR/Work"

    # =========================
    # Sätt ägare på allt
    # =========================
    chown -R "$USER:$USER" "$HOME_DIR" 2>/dev/null

    # =========================
    # Rättigheter (endast ägare)
    # =========================
    chmod 700 "$HOME_DIR/Documents"
    chmod 700 "$HOME_DIR/Downloads"
    chmod 700 "$HOME_DIR/Work"

    # =========================
    # WELCOME FILE (VIKTIG DEL 4)
    # =========================
    FILE="$HOME_DIR/welcome.txt"

    # exakt första raden
    echo "Välkommen $USER" > "$FILE"

    # tom rad
    echo "" >> "$FILE"

    # rubrik
    echo "Andra användare:" >> "$FILE"

    # lista användare (filtrerar bort systemkonton + nuvarande user)
    cut -d: -f1 /etc/passwd | grep -v "^$USER$" >> "$FILE"

    # rätt ägare och rättigheter
    chown "$USER:$USER" "$FILE" 2>/dev/null
    chmod 600 "$FILE" 2>/dev/null

done

exit 0