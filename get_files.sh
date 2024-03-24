#!/bin/bash

# Function to clone or update a repository
clone_or_update()
{
  local repo_url=$1
  local dir_name=$2
  local checkout_ref=$3

  if [ -d "$dir_name" ]; then
    echo "$dir_name directory already exists. Updating..."
    cd "$dir_name" || exit 1
    git fetch
  else
    echo "Cloning $dir_name..."
    git clone "$repo_url" "$dir_name"
    cd "$dir_name" || exit 1
  fi

  git checkout "$checkout_ref"
  cd ..
}

# Clone or update llvm-project
clone_or_update "https://github.com/llvm/llvm-project.git" "llvm-project" "9778ec057cf4"

# Clone or update onnx-mlir-lltfi
clone_or_update "https://github.com/DependableSystemsLab/onnx-mlir-lltfi.git" "onnx-mlir-lltfi" "LLTFI"
