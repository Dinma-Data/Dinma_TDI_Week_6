#!/bin/bash

#Enable debug to trace command execution
set -x

# Read the version from params.yml
Version=$(grep 'Version' param.yml | awk '{print $2}')
echo "Version: $Version"

# Retrieve the corresponding size from param.yml based on the version
Size=$(grep -E "\"?$Version\"?:" param.yml | awk '{print $2}' | tr -d ',')
echo "Size: $Size"

# Check if size was successfully retrieved
if [ -z "$Size" ]; then
echo "Error: Size could not be retrieved for version"
exit 1
fi

# Define the URL for API
API_URL="https://jsonplaceholder.typicode.com/photos"

# Ensure datahub directory exists
mkdir -p datahub

# Fetch data using curl
echo "Starting data retrieval with size curl..."
echo "Fetching data for version $Version with size $Size..."

# Test with hardcoded size for troubleshooting
eval "curl -s \"$API_URL\" | jq '.[:$Size]' > datahub/data.json"
echo "Data retrieval complete"

# Check if the newly fetched data differs from the current data
if [ -f datahub/data.json.old ];
then
if cmp -s datahub/data.json
datahub/data.json.old; then
echo "No changes; data has not changed"
exit 0
fi
fi

# If data is different, save the new data and update the old data file
cp datahub/data.json datahub/data.json.old
echo "Data has been updated for version $Version"

# Disable debug
set +x