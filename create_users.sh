#!/bin/bash

# =============================================================================
# create_users.sh
# Beskrivning: Automatiserat script för att skapa användare och sätta upp
#              deras katalogstruktur på systemet.
# Användning: sudo ./create_users.sh <användare1> <användare2> ...
# Exempel:    sudo ./create_users.sh Anna Bjorn Charlie
# =============================================================================

# Gör scriptet körbart om det inte redan är det
chmod +x "$0"

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
# 3. SKAPA ALLA ANVÄNDARE FÖRST
#    (så att alla användare finns i /etc/passwd när welcome.txt skrivs)
# -----------------------------------------------------------------------------
for ANVANDARE in "$@"; do
    if id "$ANVANDARE" &>/dev/null; then
        echo "Varning: Användaren '$ANVANDARE' finns redan."
    else
        # Skapa användaren med hemkatalog och bash som standardskal
        useradd -m -s /bin/bash "$ANVANDARE"
        if [ $? -ne 0 ]; then
            echo "Fel: Kunde inte skapa användaren '$ANVANDARE'."
            exit 1
        fi
        echo "Användaren '$ANVANDARE' skapades."
    fi
done

# -----------------------------------------------------------------------------
# 4. SÄTT UPP KATALOGER, RÄTTIGHETER OCH VÄLKOMSTFIL FÖR VARJE ANVÄNDARE
# -----------------------------------------------------------------------------
for ANVANDARE in "$@"; do

    echo "--------------------------------------------"
    echo "Konfigurerar: $ANVANDARE"

    HEMKATALOG="/home/$ANVANDARE"

    # Skapa hemkatalogen om den saknas
    if [ ! -d "$HEMKATALOG" ]; then
        mkdir -p "$HEMKATALOG"
    fi

    # Skapa de tre obligatoriska undermapparna
    mkdir -p "$HEMKATALOG/Documents"
    mkdir -p "$HEMKATALOG/Downloads"
    mkdir -p "$HEMKATALOG/Work"

    echo "Kataloger skapade: Documents, Downloads, Work"

    # Sätt rättigheter - endast ägaren kan läsa/skriva/köra (700)
    chmod 700 "$HEMKATALOG/Documents"
    chmod 700 "$HEMKATALOG/Downloads"
    chmod 700 "$HEMKATALOG/Work"

    echo "Rättigheter satta (700)."

    # -------------------------------------------------------------------------
    # Skapa welcome.txt
    # Rad 1: "Välkommen <användarnamn>"
    # Resterande rader: alla andra användare på systemet (UID >= 1000)
    # -------------------------------------------------------------------------
    VELKOMST_FIL="$HEMKATALOG/welcome.txt"

    # Rad 1: personligt välkomstmeddelande
    echo "Välkommen $ANVANDARE" > "$VELKOMST_FIL"

    # Lista alla andra riktiga användare, exkludera nuvarande användare
    while IFS=: read -r ANVNAMN _ ANVID _ _ _ _; do
        if [ "$ANVID" -ge 1000 ] && [ "$ANVNAMN" != "$ANVANDARE" ] && [ "$ANVNAMN" != "nobody" ]; then
            echo "$ANVNAMN" >> "$VELKOMST_FIL"
        fi
    done < /etc/passwd

    echo "Välkomstfil skapad."

    # Sätt rätt ägare på hela hemkatalogen
    chown -R "$ANVANDARE":"$ANVANDARE" "$HEMKATALOG"

    echo "Klar: $ANVANDARE"
done

echo "--------------------------------------------"
echo "Klart! Alla användare har skapats och konfigurerats."
exit 0


