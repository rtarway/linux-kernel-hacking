#!/bin/bash

IMAGE_NAME="kernel-hackerbox"
CONTAINER_NAME="kernel-lab"

# Docker executable path and update PATH for helpers
export PATH="$HOME/.rd/bin:$PATH"
DOCKER_CMD="docker"

# Check if container exists
if [ "$($DOCKER_CMD ps -a -q -f name=$CONTAINER_NAME)" ]; then
    echo "Found existing container: $CONTAINER_NAME"
    if [ "$($DOCKER_CMD ps -q -f name=$CONTAINER_NAME)" ]; then
        echo "Container is already running."
        echo "To enter it manually, run: $DOCKER_CMD exec -it $CONTAINER_NAME bash"
        echo "Entering container now..."
        $DOCKER_CMD exec -it $CONTAINER_NAME bash
    else
        echo "Container is stopped. Starting and attaching..."
         echo "To start it manually, run: $DOCKER_CMD start -ai $CONTAINER_NAME"
        $DOCKER_CMD start -ai $CONTAINER_NAME
    fi
else
    echo "No existing container found. Creating new one..."
    
    # Build the image
    # We need to run this from the lab directory where Dockerfile is located,
    # or specify the path to Dockerfile.
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    $DOCKER_CMD build -t $IMAGE_NAME -f "$SCRIPT_DIR/Dockerfile" "$SCRIPT_DIR"

    # Determine the repository root (one level up from this script's directory)
    REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd)

    # Run the container with the entire repo mounted
    # This ensures source code, docs, and the linux kernel are all accessible
    $DOCKER_CMD run -it --name $CONTAINER_NAME \
        -v "$REPO_ROOT":/home/hacker/workspace \
        -w /home/hacker/workspace/linux \
        $IMAGE_NAME
fi
