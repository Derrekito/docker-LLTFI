#!/bin/bash

TAG="llvm15-fault-injector"

# Create a Docker build context
docker buildx create --use --name mybuilder

# Build the Docker image using Docker Buildx
docker buildx build \
  --tag "$TAG" \
  --cache-from type=local,src=llvm-cache \
  --cache-from type=local,src=onnx-mlir-cache \
  --cache-to type=local,dest=llvm-cache \
  --cache-to type=local,dest=onnx-mlir-cache \
  --build-arg APT_CACHE_VOLUME=apt-cache \
  .

# Remove the Docker build context
docker buildx rm mybuilder
