#!/bin/bash

# =============================================================================
# create_users.sh
# Beskrivning: Skapar användare, hemkatalogstruktur och välkomstmeddelande.
#              Måste köras som root.
# Användning:   sudo ./create_users.sh <användare1> <användare2> ...
# =============================================================================

# ---------- 1. Root-kontroll ----------
if [[ $EUID -ne 0 ]]; then
    echo "Detta script måste köras som root." >&2
    exit 1
fi

if [[ $# -eq 0 ]]; then
    echo "Användning: $0 <användare1> [användare2 ...]" >&2
    exit 1
fi

# ---------- 2. Hämta redan existerande "riktiga" användare ----------
existing_users=()
while IFS=: read -r user _ uid _; do
    if (( uid >= 1000 && uid < 65534 )); then
        existing_users+=("$user")
    fi
done < /etc/passwd

# ---------- 3. Skapa alla användare först ----------
for user in "$@"; do
    # Absoluta sökvägar för att undvika PATH-problem med sudo
    if /usr/sbin/useradd -m -s /bin/bash "$user" 2>/dev/null; then
        echo "Användaren '$user' skapades."
    else
        # Om användaren redan finns fortsätter vi (annars avbryt)
        if ! id "$user" &>/dev/null; then
            echo "Fel: Kunde inte skapa '$user'." >&2
            exit 1
        fi
        echo "Varning: '$user' finns redan."
    fi
done

# ---------- 4. Konfigurera hemkatalog för varje användare ----------
for user in "$@"; do
    home="/home/$user"

    # Skapa mappar med absoluta sökvägar och sätt rätt ägare/rättigheter
    /usr/bin/install -d -m 700 -o "$user" -g "$user" "$home/Documents"
    /usr/bin/install -d -m 700 -o "$user" -g "$user" "$home/Downloads"
    /usr/bin/install -d -m 700 -o "$user" -g "$user" "$home/Work"

    # Välkomstfil
    welcome="$home/welcome.txt"
    echo "Välkommen $user" > "$welcome"

    # Lista övriga användare (de som fanns innan + de nyskapade utom sig själv)
    for other in "${existing_users[@]}"; do
        [[ "$other" != "$user" ]] && echo "$other" >> "$welcome"
    done
    # Lägg även till de nyskapade användarna som inte fanns i existing_users
    for other in "$@"; do
        if [[ "$other" != "$user" ]] && ! printf '%s\n' "${existing_users[@]}" | grep -qx "$other"; then
            echo "$other" >> "$welcome"
        fi
    done

    # Ägarskap och rättigheter för välkomstfilen
    /bin/chown "$user":"$user" "$welcome"
    /bin/chmod 600 "$welcome"

    echo "Konfiguration klar för $user"
done

exit 0

