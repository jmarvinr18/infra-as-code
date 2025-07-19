#!/bin/bash

# Path to your .env file
ENV_FILE=".env"
VAULT_PATH="internal/database/config"

# Construct the vault kv put command
CMD="vault kv put $VAULT_PATH"

# Read the env file and add each line as a key=value argument
while IFS='=' read -r key value
do
  # Skip blank lines and comments
  [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
  CMD+=" $key=\"$value\""
done < "$ENV_FILE"

# Execute the command
eval "$CMD"
