#!/bin/bash

set -e

echo "Provide some simple test passphrase:"
read -r PASSPHRASE

./generate_pgp_key.sh --image cargo --version 6 --passphrase "$PASSPHRASE"
./test_with_rsop.sh output/rfc9580_cargo.key
