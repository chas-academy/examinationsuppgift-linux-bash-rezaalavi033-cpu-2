#!/bin/bash

# =============================================
# create_users.sh
# Linux & Bash - Användarhantering
# =============================================

# Kontrollera root
if [ "$(id -u)" -ne 0 ]; then
    echo "Fel: Detta script måste köras som root (använd sudo)."
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Fel: Ange minst ett användarnamn."
    echo "Användning: $0 användarnamn1 [användarnamn2 ...]"
    exit 1
fi

for username in "$@"; do
    
    if id "$username" &>/dev/null; then
        echo "Varning: Användaren $username finns redan. Hoppar över."
        continue
    fi
    
    echo "Skapar användare: $username"
    
    useradd -m "$username" 2>/dev/null || {
        echo "Fel: Kunde inte skapa användaren $username"
        continue
    }
    
    home_dir="/home/$username"
    
    # Skapa mappar
    mkdir -p "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"
    
    # Sätt ägare och rättigheter
    chown -R "$username:$username" "$home_dir"
    chmod -R 700 "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"
    
    # === VÄLKOMSTFIL - Förbättrad ===
    welcome_file="$home_dir/welcome.txt"
    
    {
        echo "Välkommen $username"
        echo ""
        echo "Andra användare på systemet:"
        
        # Lista alla användare med UID >= 1000 utom systemanvändare och den nya
        awk -F: '$3 >= 1000 && $1 != "'"$username"'" {print $1}' /etc/passwd | sort
    } > "$welcome_file"
    
    chown "$username:$username" "$welcome_file"
    chmod 600 "$welcome_file"
    
    echo "✓ Användare $username skapad och konfigurerad."
done

echo "======================================"
echo "Alla användare har bearbetats!"

