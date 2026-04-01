#!/bin/bash

echo "Enter Zone (example: us-central1-a)"
read ZONE

export ZONE=$ZONE
export REGION=$(echo $ZONE | sed 's/-[a-z]$//')

gcloud config set compute/zone $ZONE
gcloud config set compute/region $REGION

export PROJECT_ID=$(gcloud config get-value project)

echo "ZONE=$ZONE"
echo "REGION=$REGION"
echo "PROJECT_ID=$PROJECT_ID"

# Task 1
gcloud compute firewall-rules create allow-ssh --direction=INGRESS --action=ALLOW --rules=tcp:22 --source-ranges=10.1.0.0/24,10.2.0.0/24 --description="allow-ssh" --network=external-network --target-tags=ssh

gcloud compute firewall-rules create allow-web --allow=tcp:80,tcp:443 --description="allow-web" --source-ranges=10.0.0.0/16 --network=external-network --target-tags=web

# Task 2
gcloud beta compute firewall-rules migrate --source-network=external-network --export-tag-mapping --tag-mapping-file=tag-mapping.json

# Task 3
gcloud resource-manager tags keys create vpc-tags --parent=projects/$PROJECT_ID --purpose=GCE_FIREWALL --purpose-data=network=$PROJECT_ID/external-network

gcloud resource-manager tags values create ssh --parent=$PROJECT_ID/vpc-tags
gcloud resource-manager tags values create web --parent=$PROJECT_ID/vpc-tags
gcloud resource-manager tags values create external --parent=$PROJECT_ID/vpc-tags

# Task 5
gcloud beta compute firewall-rules migrate --source-network=external-network --bind-tags-to-instances --tag-mapping-file=tag-mapping.json

# Task 6 (Migration)
gcloud beta compute firewall-rules migrate --source-network=external-network --tag-mapping-file=tag-mapping.json --target-firewall-policy=global-policy

# Task 9
gcloud compute networks update external-network --network-firewall-policy-enforcement-order=BEFORE_CLASSIC_FIREWALL

# Task 10
gcloud compute network-firewall-policies rules update 1000 --firewall-policy=global-policy --enable-logging --global-firewall-policy

echo "Subscribe to Dr Abhishek 🚀🔥"
