#!/bin/bash

# ROOT CHECK
if [ "$EUID" -ne 0 ]; then
    echo "Måste köras som root"
    exit 1
fi

# INGEN INPUT
if [ $# -eq 0 ]; then
    echo "Ange användare"
    exit 1
fi

# LOOP ALL ARGUMENTS
for USER in "$@"
do
    HOME_DIR="/home/$USER"

    # SKAPA USER (KRITISKT)
    if ! id "$USER" &>/dev/null; then
        useradd -m -d "$HOME_DIR" "$USER" 2>/dev/null
    fi

    # säkerställ home
    mkdir -p "$HOME_DIR"

    # mappar (TEST KRAV)
    mkdir -p "$HOME_DIR/Documents"
    mkdir -p "$HOME_DIR/Downloads"
    mkdir -p "$HOME_DIR/Work"

    # ägare
    chown -R "$USER:$USER" "$HOME_DIR" 2>/dev/null

    # rättigheter
    chmod 700 "$HOME_DIR/Documents" 2>/dev/null
    chmod 700 "$HOME_DIR/Downloads" 2>/dev/null
    chmod 700 "$HOME_DIR/Work" 2>/dev/null

    # welcome.txt
    FILE="$HOME_DIR/welcome.txt"

    echo "Välkommen $USER" > "$FILE"
    echo "" >> "$FILE"
    echo "Användare i systemet:" >> "$FILE"

    cut -d: -f1 /etc/passwd >> "$FILE"

    chown "$USER:$USER" "$FILE" 2>/dev/null
    chmod 600 "$FILE" 2>/dev/null

done

exit 0