#!/bin/bash

# =============================================================================
# create_users.sh
# Beskrivning: Automatiserat script för att skapa användare och sätta upp
#              deras katalogstruktur på systemet.
#
# Användning: sudo ./create_users.sh <användare1> <användare2> ...
# Exempel:    sudo ./create_users.sh Anna Bjorn Charlie
# =============================================================================

# -----------------------------------------------------------------------------
# 1. BEHÖRIGHETSKONTROLL - Kontrollera att scriptet körs som root (UID 0)
# -----------------------------------------------------------------------------
if [ "$EUID" -ne 0 ]; then
    echo "Fel: Detta script måste köras som root (superuser)."
    echo "Försök igen med: sudo $0 $*"
    exit 1
fi

# -----------------------------------------------------------------------------
# 2. KONTROLLERA ATT MINST ETT ANVÄNDARNAMN HAR ANGETTS
# -----------------------------------------------------------------------------
if [ "$#" -eq 0 ]; then
    echo "Fel: Inga användarnamn angavs."
    echo "Användning: $0 <användare1> <användare2> ..."
    exit 1
fi

# -----------------------------------------------------------------------------
# 3. LOOPAR IGENOM ALLA ANGIVNA ANVÄNDARNAMN OCH SKAPAR VARJE ANVÄNDARE
# -----------------------------------------------------------------------------
for ANVANDARE in "$@"; do

    echo "--------------------------------------------"
    echo "Bearbetar användare: $ANVANDARE"

    # Kontrollera om användaren redan finns i systemet
    if id "$ANVANDARE" &>/dev/null; then
        echo "Varning: Användaren '$ANVANDARE' finns redan. Hoppar över."
        continue
    fi

    # Skapa användaren med en hemkatalog (-m skapar hemkatalog automatiskt)
    useradd -m "$ANVANDARE"

    # Kontrollera att useradd lyckades
    if [ $? -ne 0 ]; then
        echo "Fel: Kunde inte skapa användaren '$ANVANDARE'. Hoppar över."
        continue
    fi

    echo "Användaren '$ANVANDARE' skapades."

    # -------------------------------------------------------------------------
    # 4. KATALOGSTRUKTUR - Skapa undermapparna Documents, Downloads och Work
    #    i användarens hemkatalog
    # -------------------------------------------------------------------------
    HEMKATALOG="/home/$ANVANDARE"

    # Skapa de tre obligatoriska undermapparna
    mkdir -p "$HEMKATALOG/Documents"
    mkdir -p "$HEMKATALOG/Downloads"
    mkdir -p "$HEMKATALOG/Work"

    echo "Kataloger skapade: Documents, Downloads, Work"

    # -------------------------------------------------------------------------
    # 5. RÄTTIGHETER - Sätt rättigheter så att endast ägaren kan läsa/skriva
    #    i mapparna (chmod 700 = rwx för ägaren, ingenting för andra)
    # -------------------------------------------------------------------------
    chmod 700 "$HEMKATALOG/Documents"
    chmod 700 "$HEMKATALOG/Downloads"
    chmod 700 "$HEMKATALOG/Work"

    echo "Rättigheter satta (700) på Documents, Downloads och Work."

    # -------------------------------------------------------------------------
    # 6. VÄLKOMSTMEDDELANDE - Skapa filen welcome.txt i hemkatalogen
    #    Rad 1: Personligt välkomstmeddelande
    #    Resterande rader: Lista på alla andra användare i systemet
    # -------------------------------------------------------------------------
    VELKOMST_FIL="$HEMKATALOG/welcome.txt"

    # Rad 1: Välkomstmeddelande med användarens namn
    echo "Välkommen $ANVANDARE" > "$VELKOMST_FIL"

    # Lägg till en tom rad och en rubrik för användarlistan
    echo "" >> "$VELKOMST_FIL"
    echo "Andra användare på systemet:" >> "$VELKOMST_FIL"

    # Hämta alla andra användare från /etc/passwd (UID >= 1000 = riktiga användare)
    # och exkludera den nyskapade användaren samt "nobody"
    while IFS=: read -r NAMN _ UID _ _ _ _; do
        if [ "$UID" -ge 1000 ] && [ "$NAMN" != "$ANVANDARE" ] && [ "$NAMN" != "nobody" ]; then
            echo "- $NAMN" >> "$VELKOMST_FIL"
        fi
    done < /etc/passwd

    echo "Välkomstfil skapad: $VELKOMST_FIL"

    # -------------------------------------------------------------------------
    # 7. ÄGARSKAP - Se till att hemkatalogen och alla filer ägs av användaren
    # -------------------------------------------------------------------------
    chown -R "$ANVANDARE":"$ANVANDARE" "$HEMKATALOG"

    echo "Ägarskap satt för '$ANVANDARE' på hela hemkatalogen."
    echo "Användaren '$ANVANDARE' är nu klar!"

done

echo "--------------------------------------------"
echo "Klart! Alla angivna användare har bearbetats."
exit 0
