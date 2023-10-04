#!/bin/bash

# This script applies PSA labels to all namespaces in cluster. It will prompt for a choice of:
# - PSA mode (audit, warn, enforce)
# - PSA level (restricted, baseline, privileged)
# - Whether to run as dry-run or not
#
# PREREQ: Populate a list of namespaces to exclude in ./exclude-namespaces.txt

# global vars
privNamespace=`cat exclude-namespaces.txt`
GREEN='\033[1;32m'
NC='\033[0m'

checkPrereq() {
    if [[ ! -f exclude-namespaces.txt ]]; then
        echo "exclude-namespaces.txt not found, exiting..."
        exit 1
    fi
}

listExcludedNamespaces() {
    echo "Ignoring namespaces:"
    echo "----------------------------------"
    printf '%s\n' "${privNamespace[@]}"
    echo "----------------------------------"
    echo "PSA mode:             $mode"
    echo "PSA level:            $level"
    echo "Dry-mode enabled:     $dryRun"
    echo -e "----------------------------------\n"
    echo -e "Ok to proceed? (only yes will be accepted)\n"
    read -p "Enter your choice: " choice
    case $choice in
        yes)
            echo "Proceeding..."
            ;;
        *)
            echo "Quitting..."
            exit 1
            ;;
    esac
}
    
setMode() {
    echo "Please choose a PSA mode:"
    echo "1. audit"
    echo "2. warn"
    echo "3. enforce"
    read -p "Enter your choice: " choice
    case $choice in
        1)
            mode="audit"
            ;;
        2)
            mode="warn"
            ;;
        3)
            mode="enforce"
            ;;
        *)
            echo "Invalid choice"
            exit 1
            ;;
    esac
    echo -e "PSA Mode: $mode\n"

}

setLevel() {
    echo "Please choose a PSA level:"
    echo "1. restricted"
    echo "2. baseline"
    echo "3. privileged"
    read -p "Enter your choice: " choice
    case $choice in
        1)
            level="restricted"
            ;;
        2)
            level="baseline"
            ;;
        3)
            level="privileged"
            ;;
        *)
            echo "Invalid choice"
            exit 1
            ;;
    esac
    echo -e "PSA Level: $level\n"

}

setDryRun() {
    echo "Would you like to run as dry-run?"
    echo "1. Yes"
    echo "2. No"
    read -p "Enter your choice: " choice
    case $choice in
        1)
            dryRun="true"
            ;;
        2)
            dryRun="false"
            ;;
        *)
            echo "Invalid choice"
            exit 1
            ;;
    esac
    echo -e "Dry-run: $dryRun\n"
}

dryRun() {
    for namespace in $(kubectl get namespaces | awk 'NR>1{print $1}'); do
        if [[ $privNamespace =~ $namespace ]]; then
            echo -e "${GREEN}Skipping $namespace${NC}"
        else
            echo "DRYRUN: Applying PSA $mode $level label to $namespace"
            kubectl label --dry-run=server --overwrite namespace $namespace pod-security.kubernetes.io/$mode=$level 
        fi
    done
}

apply() {
    for namespace in $(kubectl get namespaces | awk 'NR>1{print $1}'); do
        if [[ $privNamespace =~ $namespace ]]; then
            echo -e "${GREEN}Skipping $namespace${NC}"
        else
            echo "Applying PSA $mode $level label to $namespace"
            kubectl label --overwrite namespace $namespace pod-security.kubernetes.io/$mode=$level 
        fi
    done
}

run() {
    if [[ $dryRun == "true" ]]; then
        dryRun
    elif [[ $dryRun == "false" ]]; then
        apply
    fi
}

checkPrereq
setMode
setLevel
setDryRun
listExcludedNamespaces
run

