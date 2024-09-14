#!/bin/bash
set -e  # Exit on non-zero exit code from commands

# Clean up k3d clusters
k3d cluster delete --config .devcontainer/k3d.yaml