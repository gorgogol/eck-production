helm repo add elastic https://helm.elastic.co && helm repo update && helm install elastic-operator elastic/eck-operator -n elastic-system --create-namespace

kubectl wait --timeout=60s --for=condition=ready pod --selector='app.kubernetes.io/name=elastic-operator' -n elastic-system

Write-Host "Deploying storage classes for hot tier"
kubectl apply -f storageclass-hot.yaml

Start-Sleep -Seconds 10

Write-Host "Deploying storage classes for warm tier"
kubectl apply -f storageclass-warm.yaml


Start-Sleep -Seconds 10

Write-Host "Deploying license"
kubectl apply -f license.yaml

Write-Host "Applying monitoring-es.yaml ..."
kubectl apply -f monitoring-es.yaml 

Start-Sleep -Seconds 10


Write-Host "Applying elasticsearch.yaml ..."
kubectl apply -f elasticsearch.yaml 

Start-Sleep -Seconds 10

Write-Host "Deploying elasticsearch..."
$attempts = 0
$ES_Status_Command = "kubectl get  elasticsearch elasticsearch -o=jsonpath='{.status.health}'"
do {
    $attempts++
    Start-Sleep -Seconds 20
    Write-Host "..."
} until ((Invoke-Expression $ES_Status_Command) -eq "green" -or $attempts -eq 60)

Write-Host "Applying kibana.yaml ..."
kubectl apply -f kibana.yaml

Start-Sleep -Seconds 2

Write-Host "Deploying Kibana..."
$ATTEMPTS = 0
$KB_STATUS_CMD = "kubectl get  kibana kibana -o='jsonpath={.status.health}'"
do {
    $ATTEMPTS++
    Start-Sleep -Seconds 20
    Write-Host "..."
} until ((Invoke-Expression $KB_STATUS_CMD) -eq "green" -or $ATTEMPTS -eq 60)

Start-Job -ScriptBlock {
    kubectl port-forward service/elasticsearch-es-http 9200
}

$PASSWORD_JSON = kubectl get secret elasticsearch-es-elastic-user -o=jsonpath='{.data.elastic}'
$PASSWORD = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($PASSWORD_JSON))

Write-Host "Password for elasticsearch: $PASSWORD"
Write-Host "----"
Write-Host "Connect to Elasticsearch with:"
Write-Host "curl -u `"elastic:$PASSWORD`" -k `"https://localhost:9200`""
Write-Host "----"

Start-Job -ScriptBlock {
    kubectl port-forward service/kibana-kb-http 5601
}

Write-Host "----"
Write-Host "Connect to Kibana at: `"https://localhost:5601`""
Write-Host "----"


Write-Host "Applying heartbeat.yaml ..."
kubectl apply -f "heartbeat.yaml"

Write-Host "Adding a Fleet server"
kubectl apply -f "fleet.yaml"

Write-Host "Deploying external-dns..."

kubectl apply -f external-dns.yaml
Start-Sleep -Seconds 30

Write-Host "Deploying cert-manager..."
Start-Sleep -Seconds 30
helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace   --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz

Write-Host "Deploying ingress..."
kubectl apply -f ingress.yaml
Start-Sleep -Seconds 30

Write-Host "Deploying cluster issuer..."
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --set installCRDs=true --set ingressShim.defaultIssuerName=letsencrypt-prod --set ingressShim.defaultIssuerKind=ClusterIssuer

kubectl apply -f clusterissuer.yaml
Start-Sleep -Seconds 30


kubectl apply -f certificate.yaml
Start-Sleep -Seconds 30
Write-Host "Deploying certificate..."
