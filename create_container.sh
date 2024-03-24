#!/bin/bash

LOCAL_DIR="/home/derrekito/Projects/C_Rust_Fault_Injection"
CONTAINER_DIR="/shared"

IMAGE_TAG="llvm15-fault-injector"
CONTAINER_NAME="llvm15"

docker run -it -v $LOCAL_DIR:$CONTAINER_DIR -v apt-cache:/var/cache/apt/archives --name $CONTAINER_NAME $IMAGE_TAG
