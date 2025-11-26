#!/bin/bash

# maybe you need to install python3 yaml module
# in my wsl2 env this worked:
#  python3 -m venv ~/py_envs
#  source ~/py_envs/bin/activate
# then this script installed yaml module like this:

# the python3 module 'yaml' is required, and is not installed on your machine.
# Do you wish to install this program? (y/n) y
# Collecting pyyaml
#   Using cached pyyaml-6.0.3-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl.metadata (2.4 kB)
# Using cached pyyaml-6.0.3-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl (801 kB)
# Installing collected packages: pyyaml
# Successfully installed pyyaml-6.0.3

export OUTPUT_DIR=$(pwd)/kubeconform-schemas
.github/crd-extractor.sh