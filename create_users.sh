#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Must be root"
    exit 1
fi

for user in "$@"
do
    useradd -m "$user" 2>/dev/null || true

    home="/home/$user"

    mkdir -p "$home/Documents" "$home/Downloads" "$home/Work"

    chown -R "$user:$user" "$home"

    chmod 700 "$home/Documents"
    chmod 700 "$home/Downloads"
    chmod 700 "$home/Work"

    echo "Välkommen $user" > "$home/welcome.txt"
    cut -d: -f1 /etc/passwd | grep -v "^$user$" >> "$home/welcome.txt"

    chown "$user:$user" "$home/welcome.txt"
done
