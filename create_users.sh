#!/bin/bash

# ==============================================================================
# Script: create_users.sh
# Uppgift: Användarhantering i Linux
# ==============================================================================

# 1. Kontrollera att scriptet körs som root (UID 0)
if [ "$EUID" -ne 0 ]; then
    echo "Fel: Scriptet måste köras med sudo/root-rättigheter."
    exit 1
fi

# Kontrollera att användarnamn skickats som argument
if [ $# -eq 0 ]; then
    echo "Användning: $0 användare1 [användare2 ...]"
    exit 1
fi

# Loopa igenom alla argument ($@ innehåller alla namn)
for username in "$@"; do

    # 2. Skapa användaren om den inte redan finns
    # -m ser till att hemkatalogen skapas, -s sätter standard-shell
    if ! id "$username" &>/dev/null; then
        useradd -m -s /bin/bash "$username"
        echo "Skapade användaren: $username"
    else
        echo "Användaren $username finns redan. Uppdaterar mappar..."
    fi

    # Hämta sökvägen till användarens hemkatalog på ett säkert sätt
    USER_HOME=$(getent passwd "$username" | cut -d: -f6)

    # 3.1 Skapa undermappar (Documents, Downloads, Work)
    # mkdir -p skapar mappen om den inte finns utan att ge felmeddelande
    mkdir -p "$USER_HOME/Documents"
    mkdir -p "$USER_HOME/Downloads"
    mkdir -p "$USER_HOME/Work"

    # 4. Skapa välkomstfil (welcome.txt)
    # Skriver över eventuell gammal fil och sätter rubriken
    echo "Välkommen $username" > "$USER_HOME/welcome.txt"
    
    # Lista alla ANDRA användare (alla i /etc/passwd utom den aktuella användaren)
    cut -d: -f1 /etc/passwd | grep -v "^$username$" >> "$USER_HOME/welcome.txt"

    # 3.2 Rättigheter och ägarskap
    # Ändra ägare till den nya användaren för hela hemkatalogen rekursivt
    chown -R "$username":"$username" "$USER_HOME"

    # Sätt rättigheter: 700 betyder rwx------ (endast ägare har tillgång)
    chmod 700 "$USER_HOME"
    chmod 700 "$USER_HOME/Documents"
    chmod 700 "$USER_HOME/Downloads"
    chmod 700 "$USER_HOME/Work"
    
    # welcome.txt ska också vara privat (läs/skriv för ägare: 600)
    chmod 600 "$USER_HOME/welcome.txt"

    echo "Klar med konfigurering för $username."
done

echo "Alla användare har hanterats."
