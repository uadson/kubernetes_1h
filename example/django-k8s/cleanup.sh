#!/bin/bash

echo "🧹 Cleaning up Django stack..."

kubectl delete -f manifests/ --ignore-not-found=true
kubectl delete pvc --all --ignore-not-found=true
kubectl delete pv --all --ignore-not-found=true

echo "✅ Cleanup completed!"