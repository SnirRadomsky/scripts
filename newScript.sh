#!/bin/bash

# Create a directory for the swagger files
mkdir -p swagger_specs

# Function to download swagger spec
download_swagger() {
    base_url=$1
    site_name=$(echo $base_url | sed 's/https:\/\///' | sed 's/http:\/\///' | sed 's/[\/.]/_/g')
    
    # Array of common swagger file locations
    endpoints=(
        "/swagger.json"
        "/openapi.json"
        "/api-docs"
        "/v2/api-docs"
        "/openapi/user/apps/swagger.json"
        "/openapi/user/apps/openapi.json"
    )

    for endpoint in "${endpoints[@]}"; do
        url="${base_url%/}${endpoint}"
        output_file="swagger_specs/${site_name}_$(basename ${endpoint})"
        
        echo "Trying $url..."
        
        # Try to download and validate JSON
        if curl -s "$url" | jq . >/dev/null 2>&1; then
            echo "Found valid JSON at $url"
            curl -s "$url" | jq . > "$output_file"
            echo "Downloaded to $output_file"
            return 0
        fi
    done
    
    echo "No valid swagger spec found for $base_url"
    return 1
}

# Example usage - add your URLs here
urls=(
    "https://developer.transmitsecurity.com"
    # Add more URLs here
)

# Download specs for all URLs
for url in "${urls[@]}"; do
    echo "Processing $url..."
    download_swagger "$url"
    echo "------------------------"
done