#!/bin/bash

# Directory containing the files (relative to your current working directory)
DIR="ai_test_docs"

# Print the directory being processed
echo "Processing files in directory: $DIR"

# Check if the directory exists
if [ ! -d "$DIR" ]; then
  echo "Directory $DIR does not exist!"
  exit 1
fi

# Function to generate a random string (36 alphanumeric characters)
generate_random_string() {
  echo $(LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c36)
}

# Iterate over each file in the directory
for file in "$DIR"/*; do
    # Check if it's a regular file
    [ -f "$file" ] || continue

    # Extract the filename extension
    extension="${file##*.}"

    # Generate a random string for the new filename
    random_string=$(generate_random_string)

    # Construct the new filename with the random string and original extension
    new_filename="${random_string}.${extension}"

    # Rename the file
    echo "Renaming $file to $DIR/$new_filename"
    mv "$file" "$DIR/$new_filename"
done
