#!/bin/bash

set -e

chmod +x test_pgp_key.sh
chmod +x test_with_rsop.sh
for f in output/*.key; do
    ./test_pgp_key.sh --image apt --input-file $f
    ./test_pgp_key.sh --image cargo --input-file $f
    ./test_pgp_key.sh --image host --input-file $f
    ./test_with_rsop.sh $f
done
