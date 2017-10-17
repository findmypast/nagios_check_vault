#!/bin/bash

# Assumes the following:
# - The `curl` package is installed
# - Vault is listening on the standard port 8200
# - Vault is using https with a valid certificate

# The hostname of the vault server that we're supposed to check.
hostname=$1

if [ -z "$hostname" ] ; then
    echo "Usage: check_vault_seal vault_server_hostname"
    exit 3
fi

# Fetch the vault status in json format.
json=`curl -s https://${1}:8200/v1/sys/seal-status`

# Did we succeed in fetching the vault status?
if [ $? == 0 ] ; then

    # Check to see if vault is sealed.
    echo $json | jq '.sealed == false' | grep -q true
    if [ $? == 0 ] ; then
        # Good. Vault is unsealed.
        echo "OK - Vault is unsealed"
        exit 0
    else
        # Bad. Vault is sealed.
        echo "CRITICAL - Vault is sealed"
        exit 2
    fi

else

    # Failed to fetch vault status.
    echo "UNKNOWN - Failed to fetch vault seal status"
    exit 3

fi
