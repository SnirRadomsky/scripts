#!/bin/bash

# Check if tenant_id is provided
if [ $# -eq 0 ]; then
    echo "Please provide the tenant_id as an argument."
    exit 1
fi

tenant_id=$1
container_name="tip-${tenant_id}"

# Define contexts and their corresponding MongoDB hosts
us_east_context="gke_ts-prod-309222_us-east1_us-east1-1"
canada_context="gke_ts-prod-309222_northamerica-northeast1_canada-montreal-northeast1"
us_east_host="us-east1-shard-00-00-pri.h9smj.mongodb.net"
canada_host="canada-montreal-northea-shard-00-00-pri.h9smj.mongodb.net"

# Function to get pod and set MongoDB host
get_pod_and_host() {
    local context=$1
    local host=$2
    pod_name=$(kubectl get pods --namespace "${tenant_id}" | grep "^tip" | awk '{print $1}')
    if [ -n "$pod_name" ]; then
        mongo_host=$host
        return 0
    fi
    return 1
}

# Get current context
current_context=$(kubectl config current-context)

# Try to get pod in current context without switching
if [[ "$current_context" == "$us_east_context" ]]; then
    get_pod_and_host "$us_east_context" "$us_east_host"
elif [[ "$current_context" == "$canada_context" ]]; then
    get_pod_and_host "$canada_context" "$canada_host"
else
    echo "Current context is not recognized. Exiting."
    exit 1
fi

# If pod not found, try the other context
if [ -z "$pod_name" ]; then
    echo "Pod not found in current context. Trying alternative context..."
    if [[ "$current_context" == "$us_east_context" ]]; then
        kubectl config use-context "$canada_context"
        get_pod_and_host "$canada_context" "$canada_host"
    else
        kubectl config use-context "$us_east_context"
        get_pod_and_host "$us_east_context" "$us_east_host"
    fi
fi

if [ -z "$pod_name" ]; then
    echo "Pod not found in any context. Exiting."
    exit 1
fi

echo "Pod name: ${pod_name}"
echo "MongoDB host: ${mongo_host}"

# Execute the database dump command
kubectl exec "${pod_name}" --namespace "${tenant_id}" -c "${container_name}" -- /bin/bash -c "cd tmp && ../bin/ts-dbtool dump mongodb --host ${mongo_host} --port 27017 --database ${tenant_id}-auth-control-config --username ${tenant_id}-admin --password \$MONGO_DB_PW --authsource admin --ssl"

# Generate a filename with the current date
current_date=$(date +"%Y%m%d.%H%M%S")
local_dump_file="${tenant_id}-auth-control-config.${current_date}.tgz"

# Retrieve the latest dump file in a single command
kubectl exec ${pod_name} --namespace ${tenant_id} -c ${container_name} -- /bin/bash -c "latest=\$(ls -t tmp/${tenant_id}-auth-control-config.*.tgz | head -n1); cat \$latest" > "${local_dump_file}"

if [ $? -eq 0 ]; then
    echo "Dump file retrieved successfully: ${local_dump_file}"
    echo "Full path of the dump file: $(pwd)/${local_dump_file}"
else
    echo "Failed to retrieve dump file"
    exit 1
fi
