#!/bin/bash

chmod +x ./shared.sh
source ./shared.sh "$@"

INPUT=$(basename "$INPUT")

sign_something_command() {
    local cmd=("sq" "sign")
    cmd+=("/home/.gitkeep")
    cmd+=("--signer-file=/home/$INPUT")
    cmd+=(--cleartext)
    echo "${cmd[@]}"
}

bash_command="$(sign_something_command)"

docker run --rm -it \
    --volume "$(pwd)/output:/home" \
    $IMAGE \
    bash -c "$bash_command"

if [[ $? -eq 0 ]]; then
    echo "Signing succeeded for key $INPUT with image $IMAGE."
else
    echo "Signing failed for key $INPUT with image $IMAGE."
fi
