#!/bin/bash

set -e

chmod +x ./shared.sh
source ./shared.sh "$@"

INPUT=$(basename "$INPUT")

if [[ "$IMAGE" == "host" ]]; then
    DIR=output
else
    DIR=/home
fi

sign_something_command() {
    local cmd=("sq" "sign")
    cmd+=("$DIR/.gitkeep")
    cmd+=("--signer-file=$DIR/$INPUT")
    cmd+=(--cleartext)
    echo "${cmd[@]}"
}

bash_command="$(sign_something_command) > /dev/null 2>&1 && echo Signature created successfully."

echo ""
echo "Running command in image $IMAGE:"
echo "$bash_command"

if [[ "$IMAGE" == "host" ]]; then
    bash -c "$bash_command"
else
    docker run --rm -it \
        --volume "$(pwd)/output:/home" \
        $IMAGE \
        bash -c "$bash_command"
fi
