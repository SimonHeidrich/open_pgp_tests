#!/bin/bash

INPUT="$1"

if ! command -v rsop &> /dev/null; then
    echo "rsop could not be found, installing it."
    cargo install rsop
fi

echo ""
echo "Testing $INPUT with rsop."
echo "Enter the password:"
read -rs PASSWORD
echo -n "$PASSWORD" > /tmp/.password

echo "hello world" | rsop sign $INPUT --with-key-password /tmp/.password > /dev/null 2>&1 && echo "Signature successfully created."
if [[ $? -ne 0 ]]; then
    echo ""
    echo "==="
    echo "Failed to create signature using $INPUT with rsop!"
    echo "==="
    echo ""
fi
