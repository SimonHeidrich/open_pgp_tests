#!/bin/bash

set -e

chmod +x ./shared.sh
source ./shared.sh "$@"

if [[ -z "$PGP_VERSION" ]]; then
    echo "Argument --version must be provided."
    exit 1
fi

PROFILE=""
if [[ $PGP_VERSION == 4 ]] || [[ $PGP_VERSION == rfc4880 ]]; then
    PROFILE="rfc4880"
elif [[ $PGP_VERSION == 6 ]] || [[ $PGP_VERSION == rfc9580 ]]; then
    PROFILE="rfc9580"
else
    echo "Unsupported PGP version: $PGP_VERSION"
    exit 1
fi

if [[ -z "$OUTPUT" ]]; then
    PARTS=("$PROFILE")
    if [[ "$IMAGE" == "sq_via_apt" ]]; then
        PARTS+=("apt")
    else
        PARTS+=("cargo")
    fi
    OUTPUT=$(IFS=_ ; echo "${PARTS[*]}")
fi

store_passphrase_command() {
    if [[ -n "$PASSPHRASE" ]]; then
        echo "echo -n \"$PASSPHRASE\" > /tmp/.passphrase"
    else
        echo "echo \"You provided no passphrase, I'm gonna prompt you for one. Just you wait.\""
    fi
}

key_generate_command() {
    local cmd=("sq" "key" "generate")
    cmd+=("--shared-key")
    cmd+=("--profile=$PROFILE")
    cmd+=("--email=a@example.com")
    if [[ -n "$PASSPHRASE" ]]; then
        cmd+=("--new-password-file=/tmp/.passphrase")
    fi
    echo "${cmd[@]}"
}

key_export_command() {
    local cmd=("sq")
    cmd+=("--overwrite")
    cmd+=("key" "export")
    cmd+=("--output=/home/${OUTPUT}.key")
    cmd+=("--cert-email=a@example.com")
    echo "${cmd[@]}"
}

bash_command="$(store_passphrase_command) && \
    $(key_generate_command) > /dev/null 2>&1 && \
    $(key_export_command)"

docker run --rm -it \
    --volume "$(pwd)/output:/home" \
    $IMAGE \
    bash -c "$bash_command"

sudo chown "$(id -u):$(id -g)" "output/${OUTPUT}.key"

echo "Generated key saved to output/${OUTPUT}.key"
