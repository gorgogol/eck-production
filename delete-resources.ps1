# Delete certificate
Write-Host "Deleting certificate..."
kubectl delete -f certificate.yaml

# Delete cluster issuer
Write-Host "Deleting cluster issuer..."
kubectl delete -f clusterissuer.yaml

# Delete ingress-nginx
Write-Host "Deleting ingress-nginx..."
helm uninstall ingress-nginx -n ingress-nginx

# Delete cert-manager
Write-Host "Deleting cert-manager..."
helm uninstall cert-manager -n cert-manager
#helm install cert-manager jetstack/cert-manager --namespace cert-manager --set installCRDs=true --set ingressShim.defaultIssuerName=letsencrypt --set ingressShim.defaultIssuerKind=ClusterIssuer

# Delete external-dns
Write-Host "Deleting external-dns..."
kubectl delete -f external-dns.yaml

# Delete fleet
Write-Host "Deleting Fleet server..."
kubectl delete -f fleet.yaml

# Delete heartbeat
Write-Host "Deleting heartbeat..."
kubectl delete -f heartbeat.yaml

# Delete Kibana
Write-Host "Deleting Kibana..."
kubectl delete -f kibana.yaml

# Delete Elasticsearch
Write-Host "Deleting Elasticsearch..."
kubectl delete -f elasticsearch.yaml

# Delete monitoring-es
Write-Host "Deleting monitoring-es..."
kubectl delete -f monitoring-es.yaml

# Delete license
Write-Host "Deleting license..."
kubectl delete -f license.yaml

# Delete storage classes for warm tier
Write-Host "Deleting storage classes for warm tier..."
kubectl delete -f storageclass-warm.yaml

# Delete storage classes for hot tier
Write-Host "Deleting storage classes for hot tier..."
kubectl delete -f storageclass-hot.yaml

# Delete elastic-operator
Write-Host "Deleting elastic-operator..."
helm uninstall elastic-operator -n elastic-system



Write-Host "Cleanup completed."
