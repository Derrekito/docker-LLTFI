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

# Install LLVM 15.0
RUN git clone https://github.com/llvm/llvm-project.git && \
    cd llvm-project && \
    git checkout 9778ec057cf4 && \
    mkdir build && cd build && \
    cmake -G Ninja ../llvm \
        -DLLVM_ENABLE_PROJECTS="clang;mlir" \
        -DLLVM_BUILD_TESTS=ON \
        -DLLVM_TARGETS_TO_BUILD="host" \
        -DLLVM_ENABLE_ASSERTIONS=ON \
        -DLLVM_ENABLE_RTTI=ON && \
    cmake --build . --target clang check-mlir mlir-translate opt llc lli llvm-dis llvm-link -j$(nproc) && \
    ninja install

# Clone and install ONNX-MLIR (LLTFI branch)
ENV MLIR_DIR=/llvm-project/build/lib/cmake/mlir
RUN git clone --recursive https://github.com/DependableSystemsLab/onnx-mlir-lltfi.git onnx-mlir && \
    cd onnx-mlir && \
    git checkout LLTFI && \
    mkdir build && cd build && \
    cmake -G Ninja \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DMLIR_DIR=${MLIR_DIR} \
        .. && \
    cmake --build . && \
    cmake --build . --target check-onnx-lit && \
    ninja install

# Setup LLTFI
# You might need to clone the LLTFI repo if not included in onnx-mlir or download the InstallLLTFI.py script directly
RUN wget https://raw.githubusercontent.com/DependableSystemsLab/LLTFI/master/installer/InstallLLTFI.py
RUN python3 /InstallLLTFI.py

# Set work directory
WORKDIR /project

# Default command
CMD ["/bin/bash"]
