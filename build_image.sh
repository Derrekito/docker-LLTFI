#!/bin/bash

export DOCKER_BUILDKIT=1

TAG="llvm15-fault-injector"

# Ensure the cache directories exist
mkdir -p llvm-cache onnx-mlir-cache

# Create a Docker build context
docker buildx create --use --name mybuilder

# Build the Docker image using Docker Buildx
docker buildx build \
  --tag "$TAG" \
  --cache-from=type=local,src=llvm-cache \
  --cache-from=type=local,src=onnx-mlir-cache \
  --cache-to=type=local,mode=max,dest=llvm-cache \
  --cache-to=type=local,mode=max,dest=onnx-mlir-cache \
  --load \
  .

# Remove the Docker build context
docker buildx rm mybuilder
