#!/bin/bash

set -e

echo "Provide some simple test passphrase (you will need to enter it several times):"
read -r PASSPHRASE

chmod +x ./generate_pgp_key.sh
./generate_pgp_key.sh --image apt --version 4 --passphrase "$PASSPHRASE"
./generate_pgp_key.sh --image apt --version 4
./generate_pgp_key.sh --image apt --version 6 --passphrase "$PASSPHRASE"
./generate_pgp_key.sh --image apt --version 6
./generate_pgp_key.sh --image cargo --version 4 --passphrase "$PASSPHRASE"
./generate_pgp_key.sh --image cargo --version 4
./generate_pgp_key.sh --image cargo --version 6 --passphrase "$PASSPHRASE"
./generate_pgp_key.sh --image cargo --version 6
