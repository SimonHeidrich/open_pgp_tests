while [[ $# -gt 0 ]]; do
    case "$1" in
        --image|-i)
            IMAGE="$2"
            shift 2
            ;;
        --input-file|-f)
            INPUT="$2"
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
elif [[ "$IMAGE" == "host" ]]; then
    IMAGE="host"
else
    echo "Unsupported image: $IMAGE"
    echo "Supported images are: apt, cargo, host (only during signing tests)"
    exit 1
fi

if [[ "$IMAGE" != "host" ]]; then
    if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
        echo "Docker image $IMAGE does not exist."
        echo "Building it..."
        chmod +x ./build_containers.sh
        ./build_containers.sh --image "$IMAGE"
    fi
fi
