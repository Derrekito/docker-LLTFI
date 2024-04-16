# Use Ubuntu 20.04 LTS as the base image
FROM ubuntu:20.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    python3 \
    python3-pip \
    ninja-build \
    wget \
    libprotoc-dev \
    protobuf-compiler \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Rust (using rustup)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Set the PATH for Rust
ENV PATH="/root/.cargo/bin:${PATH}"

# Install TensorFlow, numpy, and tf2onnx
RUN pip3 install tensorflow numpy tf2onnx

# Use BuildKit to mount the source code directories
# Mount the LLVM project
RUN --mount=type=bind,target=/llvm-project,source=./llvm-project,readwrite \
    mkdir -p /llvm-project/build && \
    cmake -G Ninja -S /llvm-project/llvm -B /llvm-project/build \
    -DLLVM_ENABLE_PROJECTS="clang;mlir" \
    -DLLVM_BUILD_TESTS=ON \
    -DLLVM_TARGETS_TO_BUILD="host" \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DLLVM_ENABLE_RTTI=ON && \
    cmake --build /llvm-project/build --target clang check-mlir mlir-translate opt llc lli llvm-dis llvm-link -j$(nproc) && \
    ninja -C /llvm-project/build install

# Mount the ONNX-MLIR repository
RUN --mount=type=bind,target=/onnx-mlir-lltfi,source=./onnx-mlir-lltfi,readwrite \
    mkdir -p /onnx-mlir-lltfi/build && \
    git -C /onnx-mlir-lltfi checkout LLTFI && \
    cmake -G Ninja -S /onnx-mlir-lltfi -B /onnx-mlir-lltfi/build \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DMLIR_DIR=/llvm-project/build/lib/cmake/mlir && \
    cmake --build /onnx-mlir-lltfi/build && \
    cmake --build /onnx-mlir-lltfi/build --target check-onnx-lit && \
    ninja -C /onnx-mlir-lltfi/build install

# Set work directory
WORKDIR /project

# Default command
CMD ["/bin/bash"]
