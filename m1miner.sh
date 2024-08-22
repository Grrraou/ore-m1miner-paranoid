#!/bin/bash

# Define variables
IMAGE_NAME="ubuntu:24.04"
CONTAINER_NAME="ore-m1miner-paranoid-container"
SOLANA_ADDRESS="B4gXwwawYixf3uXYrbSmZuo5koNH4pGdw5RYZm4kzdBt"  # Replace with your actual Solana address
BINARY_URL="http://static.m1pool.xyz/m1miner"  # Replace with your actual binary URL
BINARY_NAME="p"              # Name of the binary once downloaded

# Step 1: Create Dockerfile
cat <<EOF > Dockerfile
# Use the specified base image
FROM $IMAGE_NAME

# Install necessary utilities like curl
RUN apt-get update && apt-get install -y curl

# Create directory for Solana address
RUN mkdir -p /ore

EOF

# Build the Docker image
echo "Building Docker image..."
docker build -t m1miner-image .

# Stop and remove any existing container with the same name
echo "Removing any existing container with the name $CONTAINER_NAME..."
docker rm -f $CONTAINER_NAME

# Run the Docker container in detached mode and keep it running
echo "Running Docker container..."
docker run -d --name $CONTAINER_NAME m1miner-image sleep infinity

# Download the binary using curl inside the container
echo "Downloading binary inside the container..."
docker exec -i $CONTAINER_NAME bash -c "curl -o /ore/$BINARY_NAME $BINARY_URL"

# Make the binary executable
echo "Making the binary executable..."
docker exec -i $CONTAINER_NAME bash -c "chmod +x /ore/$BINARY_NAME"

# Execute the binary with the Solana address and show all output
echo "Executing the binary with the Solana address and showing all output..."
docker exec -it $CONTAINER_NAME bash -c "/ore/$BINARY_NAME wallet=$SOLANA_ADDRESS"

# Cleanup - stop and remove the container
docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME

echo "Execution complete!"
