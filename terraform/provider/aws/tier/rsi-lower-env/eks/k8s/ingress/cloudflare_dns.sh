#!/bin/bash

# Cloudflare API credentials
CF_EMAIL="subscriptions@reliasourcing.com"
CF_API_KEY="1424dc59f17b2ba6a0c0e77c1d411bc4f1f94"
CF_ZONE_ID="64afbe0674fa5e68c2f697a9849dc5ef"

# Domain and DNS record to update
DOMAIN="rsi-techzone.xyz"
RECORD_NAME=$1
RECORD_TYPE=$2
NEW_CONTENT=$3
RECORD_TTL="auto"
RECORD_PROXIED=false

# cflare-dns.sh jimboy CNAME testdns.com

# Get the record ID
RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records?type=$RECORD_TYPE&name=$RECORD_NAME.$DOMAIN" \
    -H "X-Auth-Email: $CF_EMAIL" \
    -H "X-Auth-Key: $CF_API_KEY" \
    -H "Content-Type: application/json" | jq -r '.result[0].id')
    

echo "record ID : $RECORD_ID"

if [ "$RECORD_ID" = "null" ] || [ ! -n "$RECORD_ID" ]; then

    echo "create dns : $RECORD_ID"
    
    # Create a new DNS record with the provided parameters
    CREATE_RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records" \
        -H "X-Auth-Email: $CF_EMAIL" \
        -H "X-Auth-Key: $CF_API_KEY" \
        -H "Content-Type: application/json" \
        --data '{
        "type": "'"$RECORD_TYPE"'",
        "name": "'"$RECORD_NAME"'.'"$DOMAIN"'",
        "content": "'"$NEW_CONTENT"'",
        "ttl": 3600,
        "proxied": false,
        "comment": "Created via script"
    }')

    # Parse the response to get the new RECORD_ID
    RECORD_ID=$(echo "$CREATE_RESPONSE" | jq -r '.result.id')

    # Check if RECORD_ID is empty
    if [ -z "$RECORD_ID" ]; then
        echo "Error: Failed to create DNS record."
        return
    fi

else

    echo "updating dns..."
    # Update the DNS record with new content 
    UPDATE_RESPONSE=$(curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records/$RECORD_ID" \
        -H "X-Auth-Email: $CF_EMAIL" \
        -H "X-Auth-Key: $CF_API_KEY" \
        -H "Content-Type: application/json" \
        --data '{
        "content": "'"$NEW_CONTENT"'",
        "name": "'"$RECORD_NAME"'.'"$DOMAIN"'",
        "proxied": false,
        "type": "'"$RECORD_TYPE"'",
        "comment": "Updated via script",
        "ttl": 3600
    }')

    echo "$UPDATE_RESPONSE"

fi

