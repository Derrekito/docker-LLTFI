#!/bin/bash

TAG="llvm15-fault-injector"

docker build --tag "$TAG" --build-arg APT_CACHE_VOLUME=apt-cache .

