#!/bin/bash

# =========================
# 1. ROOT CHECK
# =========================
if [ "$EUID" -ne 0 ]; then
    echo "Fel: Scriptet måste köras som root."
    exit 1
fi

# =========================
# 2. CHECK INPUT
# =========================
if [ $# -eq 0 ]; then
    echo "Användning: ./create_users.sh user1 user2 ..."
    exit 1
fi

# =========================
# 3. CREATE USERS
# =========================
for USER in "$@"
do
    # Skapa användare (ignorera om den finns)
    if ! id "$USER" &>/dev/null; then
        useradd -m "$USER"
    fi

    HOME_DIR="/home/$USER"

    # =========================
    # 4. CREATE FOLDERS
    # =========================
    mkdir -p "$HOME_DIR/Documents" "$HOME_DIR/Downloads" "$HOME_DIR/Work"

    # =========================
    # 5. SET OWNERSHIP
    # =========================
    chown -R "$USER:$USER" "$HOME_DIR"

    # =========================
    # 6. PERMISSIONS (STRICT)
    # =========================
    chmod 700 "$HOME_DIR/Documents"
    chmod 700 "$HOME_DIR/Downloads"
    chmod 700 "$HOME_DIR/Work"

    # =========================
    # 7. WELCOME FILE
    # =========================
    WELCOME="$HOME_DIR/welcome.txt"

    echo "Välkommen $USER" > "$WELCOME"
    echo "" >> "$WELCOME"
    echo "Användare i systemet:" >> "$WELCOME"

    # Lista ALLA riktiga system users (test kräver detta)
    cut -d: -f1 /etc/passwd >> "$WELCOME"

    # =========================
    # 8. FINAL PERMISSION
    # =========================
    chown "$USER:$USER" "$WELCOME"
    chmod 600 "$WELCOME"

done

exit 0