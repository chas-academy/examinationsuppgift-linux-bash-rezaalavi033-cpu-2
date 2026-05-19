#!/bin/bash

# =============================================
# create_users.sh
# Linux & Bash - Användarhantering
# =============================================

# Här kontrollerar jag att scriptet körs som root. Om inte, stoppas det.
if [ "$(id -u)" -ne 0 ]; then
    echo "Fel: Detta script måste köras som root (använd sudo)."
    exit 1
fi

#Här kollar jag att man har skrivit in användarnamn. Annars visas ett fel.
if [ $# -eq 0 ]; then
    echo "Fel: Ange minst ett användarnamn."
    echo "Användning: $0 användarnamn1 [användarnamn2 ...]"
    exit 1
fi

# Steg 1: Skapa alla användare först
# Här loopar scriptet genom alla användare.
for username in "$@"; do
    if id "$username" &>/dev/null; then
        echo "Varning: Användaren $username finns redan. Hoppar över."
        continue
    fi
    
    echo "Skapar användare: $username"
#Här skapas användaren
#Detta skapar användaren och hemkatalogen.
    useradd -m "$username" 2>/dev/null || {
        echo "Fel: Kunde inte skapa användaren $username"
        continue
    }
#Här skapas tre mappar i hemkatalogen.
    home_dir="/home/$username"
    mkdir -p "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"
    chown -R "$username:$username" "$home_dir"
#Här gör jag så bara ägaren kan läsa och skriva
    chmod -R 700 "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"
done

# Steg 2: här Skapas välkomstfiler efter att alla användare är skapade
for username in "$@"; do
    home_dir="/home/$username"
    welcome_file="$home_dir/welcome.txt"
    
    {
        #Här skrivs första raden i filen
        echo "Välkommen $username"
        echo ""
        echo "Andra användare på systemet:"
        
        # Här listas andra användare i systemet.
        awk -F: '$3 >= 1000 && $1 != "'"$username"'" {print $1}' /etc/passwd | sort
    } > "$welcome_file"
    
    #Här sätter jag rätt ägare och skydd på filen.
    chown "$username:$username" "$welcome_file"
    chmod 600 "$welcome_file"
    
    echo "✓ Välkomstfil skapad för $username"
done

echo "======================================"
echo "Alla användare har bearbetats!"
echo "======================================"