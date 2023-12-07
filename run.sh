#!/bin/bash

# Controleer of het juiste aantal parameters is opgegeven
if [ "$#" -ne 2 ]; then
    echo "Gebruik: $0 <foto_directory> <maand|week>"
    exit 1
fi

# Sla de parameters op
photo_directory="$1"
organize_option="$2"

# Controleer of de foto_directory bestaat
if [ ! -d "$photo_directory" ]; then
    echo "Fout: De opgegeven directory bestaat niet."
    exit 1
fi

# Functie om de hash van een bestand te berekenen
calculate_hash() {
    md5sum "$1" | awk '{print $1}'
}

# Functie om foto's te verplaatsen en controleren op succesvolle verplaatsing
move_and_verify() {
    source_file="$1"
    destination="$2"

    # Verplaats het bestand naar de bestemming
    mv "$source_file" "$destination"

    # Controleer of de verplaatsing succesvol was
    if [ $? -eq 0 ]; then
        echo "Verplaatsing succesvol: $source_file -> $destination"
    else
        echo "Fout bij verplaatsen: $source_file"
        exit 1
    fi
}

# Variabelen voor originele en gekopieerde foto's
original_photo=""
copied_photo=""

# Organiseer foto's op basis van de opgegeven optie (maand/week)
case "$organize_option" in
    "maand")
        # Verplaats foto's naar de juiste map op basis van de maand
        for photo in "$photo_directory"/*; do
            month=$(date -r "$photo" +"%m")
            mkdir -p "$photo_directory/$month"
            move_and_verify "$photo" "$photo_directory/$month/"
            original_photo="$photo"
            copied_photo="$photo_directory/$month/$(basename "$photo")"
        done
        ;;
    "week")
        # Verplaats foto's naar de juiste map op basis van de week
        for photo in "$photo_directory"/*; do
            week=$(date -r "$photo" +"%U")
            mkdir -p "$photo_directory/week_$week"
            move_and_verify "$photo" "$photo_directory/week_$week/"
            original_photo="$photo"
            copied_photo="$photo_directory/week_$week/$(basename "$photo")"
        done
        ;;
    *)
        echo "Ongeldige optie. Gebruik 'maand' of 'week'."
        exit 1
        ;;
esac

# Verwijder originele foto als de kopie succesvol is
original_hash=$(calculate_hash "$original_photo")
copy_hash=$(calculate_hash "$copied_photo")

if [ "$original_hash" == "$copy_hash" ]; then
    rm "$original_photo"
    echo "Originele foto verwijderd: $original_photo"
else
    echo "Fout bij het verwijderen van originele foto: $original_photo"
fi

echo "Organisatie voltooid."
