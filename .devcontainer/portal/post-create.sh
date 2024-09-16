#!/bin/bash
set -e  # Exit on non-zero exit code from commands

echo "$(date): Running post-create.sh" >> ~/.status.log

# this runs in background after UI is available

# k3d cluster create --config .devcontainer/k3d.yaml --wait --verbose 2>&1 | tee -a ~/.status.log

echo "$(date): Finished post-create.sh" >> ~/.status.log