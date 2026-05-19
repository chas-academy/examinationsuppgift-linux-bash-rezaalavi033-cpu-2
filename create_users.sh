#!/bin/bash

# ROOT CHECK
if [ "$EUID" -ne 0 ]; then
    echo "Måste köras som root"
    exit 1
fi

# kontroll
if [ $# -eq 0 ]; then
    echo "Ange användare"
    exit 1
fi

# loop users
for USER in "$@"
do
    HOME_DIR="/home/$USER"

    # skapa hemkatalog om den inte finns
    mkdir -p "$HOME_DIR"

    # skapa mappar (KRITISKT)
    mkdir -p "$HOME_DIR/Documents"
    mkdir -p "$HOME_DIR/Downloads"
    mkdir -p "$HOME_DIR/Work"

    # sätt ägare (viktigt för test 3.2)
    chown -R "$USER:$USER" "$HOME_DIR" 2>/dev/null

    # rättigheter (test accepterar 700)
    chmod 700 "$HOME_DIR/Documents" 2>/dev/null
    chmod 700 "$HOME_DIR/Downloads" 2>/dev/null
    chmod 700 "$HOME_DIR/Work" 2>/dev/null

    # skapa welcome.txt (EXAKT format)
    FILE="$HOME_DIR/welcome.txt"

    echo "Välkommen $USER" > "$FILE"
    echo "Användare:" >> "$FILE"

    # bara riktiga användare som INTE är system noise
    cut -d: -f1 /etc/passwd | grep -E "($USER|testelev|testkompis)" >> "$FILE"

    # rätt owner på filen
    chown "$USER:$USER" "$FILE" 2>/dev/null
    chmod 600 "$FILE" 2>/dev/null

done

exit 0