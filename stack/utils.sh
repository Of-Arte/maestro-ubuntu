#!/bin/bash

# Hardening: Network Retry Wrapper
with_retries() {
    local n=1
    local max=3
    local delay=5
    while true; do
        "$@" && break || {
            if [[ $n -lt $max ]]; then
                ((n++))
                echo "Command failed. Attempt $n/$max in ${delay}s..."
                sleep $delay
            else
                echo "The command has failed after $max attempts."
                return 1
            fi
        }
    done
}
