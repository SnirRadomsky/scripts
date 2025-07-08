#!/bin/bash

# Check if tenant_id and dump file are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <tenant_id> <dump_file>"
    exit 1
fi

tenant_id=$1
dump_file=$2
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
    pod_name=$(kubectl get pods --namespace "${tenant_id}" | grep "${tenant_id}" | awk '{print $1}')
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

# Copy the dump file to the pod
dump_file_name=$(basename "${dump_file}")
kubectl cp "${dump_file}" "${tenant_id}/${pod_name}:/tmp/${dump_file_name}" -c "${container_name}"

if [ $? -ne 0 ]; then
    echo "Failed to copy dump file to the pod. Exiting."
    exit 1
fi

# Find ts-dbtool location
ts_dbtool_path=$(kubectl exec "${pod_name}" --namespace "${tenant_id}" -c "${container_name}" -- /bin/bash -c "find / -name ts-dbtool 2>/dev/null | head -n 1")

if [ -z "$ts_dbtool_path" ]; then
    echo "ts-dbtool not found in the container. Exiting."
    exit 1
fi

echo "ts-dbtool found at: ${ts_dbtool_path}"

# Add confirmation prompt
read -p "Are you sure you want to restore the database for tenant ${tenant_id}? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Database restore cancelled."
    exit 1
fi

# Execute the database restore command
kubectl exec "${pod_name}" --namespace "${tenant_id}" -c "${container_name}" -- /bin/bash -c "cd /tmp && ${ts_dbtool_path} restore mongodb --host ${mongo_host} --port 27017 --database ${tenant_id}-auth-control-config --username ${tenant_id}-admin --password \$MONGO_DB_PW --authsource admin --ssl -f ${dump_file_name}"

if [ $? -eq 0 ]; then
    echo "Database restore completed successfully."
else
    echo "Failed to restore database."
    exit 1
fi

# Clean up the dump file from the pod
kubectl exec "${pod_name}" --namespace "${tenant_id}" -c "${container_name}" -- /bin/bash -c "rm /tmp/${dump_file_name}"

echo "Restore process completed."