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

# Functie om foto's te kopiëren en controleren op succesvolle kopie
copy_and_verify() {
    source_file="$1"
    destination="$2"

    # Kopieer het bestand naar de bestemming
    cp "$source_file" "$destination"

    # Controleer of de kopie succesvol was
    if [ $? -eq 0 ]; then
        echo "Kopie succesvol: $source_file -> $destination"
    else
        echo "Fout bij kopiëren: $source_file"
        exit 1
    fi
}

# Organiseer foto's op basis van de opgegeven optie (maand/week)
case "$organize_option" in
    "maand")
        # Verplaats foto's naar de juiste map op basis van de maand
        for photo in "$photo_directory"/*; do
            month=$(date -r "$photo" +"%m")
            
            if [ ! -d "$photo_directory/$month" ]; then
                mkdir -p "$photo_directory/$month"
            fi

            copy_and_verify "$photo" "$photo_directory/$month/"
        done
        ;;
    "week")
        # Verplaats foto's naar de juiste map op basis van de week
        for photo in "$photo_directory"/*; do
            week=$(date -r "$photo" +"%U")
            
            if [ ! -d "$photo_directory/week_$week" ]; then
                mkdir -p "$photo_directory/week_$week"
            fi

            copy_and_verify "$photo" "$photo_directory/week_$week/"
        done
        ;;
    *)
        echo "Ongeldige optie. Gebruik 'maand' of 'week'."
        exit 1
        ;;
esac

# Verwijder originele foto's als de kopieën succesvol zijn
for photo in "$photo_directory"/*; do
    original_photo="$photo"
    copied_photo="$photo_directory/$month/$(basename "$photo")"
    
    original_hash=$(calculate_hash "$original_photo")
    copy_hash=$(calculate_hash "$copied_photo")

    if [ "$original_hash" == "$copy_hash" ]; then
        rm "$original_photo"
        echo "Originele foto verwijderd: $original_photo"
    else
        echo "Fout bij het verwijderen van originele foto: $original_photo"
    fi
done

echo "Organisatie voltooid."
