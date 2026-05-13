#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Du måste köra scriptet som root."
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Användning: $0 användare1 användare2"
    exit 1
fi

# Loop genom alla användare
for USERNAME in "$@"
do

    # Skapa användare med hemkatalog
    useradd -m "$USERNAME"

    # Skapa mappar
    mkdir -p /home/"$USERNAME"/Documents
    mkdir -p /home/"$USERNAME"/Downloads
    mkdir -p /home/"$USERNAME"/Work

    # Sätt ägare
    chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"

    # Sätt rättigheter
    chmod 700 /home/"$USERNAME"/Documents
    chmod 700 /home/"$USERNAME"/Downloads
    chmod 700 /home/"$USERNAME"/Work

    # Skapa welcome.txt
    echo "Välkommen $USERNAME" > /home/"$USERNAME"/welcome.txt

    # Lista andra användare
    cut -d: -f1 /etc/passwd | grep -v "^$USERNAME$" >> /home/"$USERNAME"/welcome.txt

    chown "$USERNAME":"$USERNAME" /home/"$USERNAME"/welcome.txt

done
