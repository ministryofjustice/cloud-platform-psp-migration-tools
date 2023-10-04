#!/bin/bash

# This script will find namespace yaml files without the label pod-security.kubernetes.io/audit: restricted
# Run in namespaces/[cluster-name] folder in environments repo
# PREREQ: requires yq tool installed: brew install yq

GREEN='\033[1;32m'
RED='\033[0;31m'
NC='\033[0m'

for dir in ./*; do
  if [ -d "$dir" ]; then
    labels=$(yq '.metadata.labels' "$dir/00-namespace.yaml")
    if [ -z "$(echo "$labels" | grep 'pod-security.kubernetes.io/audit')" ]; then
      echo -e "${RED}No pod-security.kubernetes.io/audit label found in $dir/00-namespace.yaml${NC}"
    else
      echo -e "${GREEN}Found pod-security.kubernetes.io/audit label in $dir/00-namespace.yaml${NC}"
    fi
  fi
done