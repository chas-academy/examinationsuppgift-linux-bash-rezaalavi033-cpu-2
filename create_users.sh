#!/bin/bash

# ==============================================================================
# Script: create_users.sh
# Uppgift: Användarhantering i Linux
# ==============================================================================


if [ "$EUID" -ne 0 ]; then
    echo "Error: Run as root"
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Usage: $0 user1 user2..."
    exit 1
fi

for user in "$@"; do
    # Skapa användare om den inte finns
    if ! id "$user" &>/dev/null; then
        useradd -m "$user"
    fi

    HOME_DIR="/home/$user"

    # Skapa mappar
    mkdir -p "$HOME_DIR/Documents"
    mkdir -p "$HOME_DIR/Downloads"
    mkdir -p "$HOME_DIR/Work"

    echo "Välkommen $user" > "$HOME_DIR/welcome.txt"
    # Lista alla andra användare (ta bort den aktuella användaren från listan)
    cut -d: -f1 /etc/passwd | grep -v "^$user$" >> "$HOME_DIR/welcome.txt"

    chown -R "$user":"$user" "$HOME_DIR"
    chmod 700 "$HOME_DIR"
    chmod 700 "$HOME_DIR/Documents"
    chmod 700 "$HOME_DIR/Downloads"
    chmod 700 "$HOME_DIR/Work"
    chmod 600 "$HOME_DIR/welcome.txt"
done

echo "Alla användare har hanterats."
