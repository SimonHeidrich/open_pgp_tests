#!/bin/bash

set -e

while [[ $# -gt 0 ]]; do
    case "$1" in
        --image|-i)
            IMAGE="$2"
            shift 2
            ;;
        --output|-o)
            OUTPUT="$2"
            shift 2
            ;;
        --passphrase|-p)
            PASSPHRASE="$2"
            shift 2
            ;;
        --version|-v)
            PGP_VERSION="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [[ -z "$IMAGE" ]]; then
    echo "Argument --image must be provided."
    exit 1
fi

if [[ "$IMAGE" == "sq_via_apt" ]] || [[ "$IMAGE" == "apt" ]]; then
    IMAGE="sq_via_apt"
elif [[ "$IMAGE" == "sq_via_cargo" ]] || [[ "$IMAGE" == "cargo" ]]; then
    IMAGE="sq_via_cargo"
else
    echo "Unsupported image: $IMAGE"
    exit 1
fi

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
    if [[ -n "$PASSPHRASE" ]]; then
        PARTS+=("scripted_passphrase")
    else
        PARTS+=("prompted_passphrase")
    fi
    OUTPUT=$(IFS=_ ; echo "${PARTS[*]}")
fi

if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
    echo "Docker image $IMAGE does not exist."
    echo "Building it..."
    chmod +x ./build_containers.sh
    ./build_containers.sh --image "$IMAGE"
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
