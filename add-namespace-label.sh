#!/bin/bash

# This script will update namespace yaml files with label pod-security.kubernetes.io/audit: restricted
# PREREQ: requires yq tool installed: brew install yq

for dir in ./*; do
  if [ -d "$dir" ]; then
    echo "Updating $dir/00-namespace.yaml"
    yq -i '.metadata.labels."pod-security.kubernetes.io/audit" = "restricted"' "$dir/00-namespace.yaml"
  fi
done