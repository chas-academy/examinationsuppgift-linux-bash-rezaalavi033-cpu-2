#!/bin/bash
# Skapar användare, hemkatalog med mappar och welcome.txt.

set -e

# Endast root får köra scriptet
if [ "$(id -u)" -ne 0 ]; then
    echo "Fel: kör med sudo (root krävs)." >&2
    exit 1
fi

# Skapa alla användare först så de syns i listan i welcome.txt
for user in "$@"; do
    useradd -m "$user"
done

for user in "$@"; do
    home="/home/$user"

    # Standardmappar, bara ägaren får läsa/skriva (700)
    mkdir -p "$home/Documents" "$home/Downloads" "$home/Work"
    chown -R "$user:$user" "$home/Documents" "$home/Downloads" "$home/Work"
    chmod 700 "$home/Documents" "$home/Downloads" "$home/Work"

    # Rad 1: välkommen. Resten: övriga användare på systemet
    {
        echo "Välkommen $user"
        cut -d: -f1 /etc/passwd | grep -Fvx "$user"
    } >"$home/welcome.txt"
    chown "$user:$user" "$home/welcome.txt"
done
