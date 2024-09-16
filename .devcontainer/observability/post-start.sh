#!/bin/bash
set -e  # Exit on non-zero exit code from commands

echo "$(date): Running post-start.sh" >> ~/.status.log

# this runs in background each time the container starts

# Ensure kubeconfig is set up. 
k3d kubeconfig merge cnp-local-demo --kubeconfig-merge-default

echo "$(date): Finished post-start.sh" >> ~/.status.log