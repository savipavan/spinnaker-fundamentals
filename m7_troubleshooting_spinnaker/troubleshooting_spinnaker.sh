## General Troubleshooting steps

### get the pod name
kubectl get pods -n spinnaker | grep 

### Check application logs
kubectl logs -n spinnaker spin-gate-d96cfb978-hvnlf -f

### Health checks
kubectl get pods -n spinnaker 

### Deploy latest spinnaker settings
hal deploy apply


## Deploy loki
### Add & update the helm repository
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update grafana

### Deploy promtail and loki
helm upgrade --install promtail grafana/promtail --namespace infra --version 3.8.1 -f loki/values-promtail.yaml
helm upgrade --install loki-distributed grafana/loki-distributed --namespace infra --version 0.63.1 -f loki/values-loki.yaml

### Get loki pods
kubectl get pods -n infra | grep loki

## Deploy Grafana
helm upgrade --install grafana grafana/grafana --namespace infra --version 6.29.4 -f grafana/values.yaml

### Port-forward grafana
kubectl port-forward -n infra svc/grafana 3000:80


### Loki query:

### Return lines including the text "error" or "info" using regex
{app="gate",namespace="spinnaker"} |= "INFO"

### Get the count of logs during the last five minutes, grouping by level:
sum(count_over_time({app="gate",namespace="spinnaker"}[5m])) by (level)

### Get the top 10 applications by the highest log throughput:
topk(10,sum(rate({namespace="spinnaker"}[5m])) by (app))


## Deploy Prom-stack
### Add and update prom repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update prometheus-community

### Deploy prometheus
helm upgrade --install prom-stack prometheus-community/kube-prometheus-stack --namespace infra --version 41.7.4 -f promstack/values.yaml

### Get prometheus pods
kubectl get pods -n infra | grep prom


### Expose application metrics
hal config metric-stores prometheus enable
hal deploy apply

### Deploy service monitors
kubectl apply -f promstack/service-monitors/

### port forward prometheus
kubectl port-forward -n infra svc/prometheus-operated 9090

## Alerting
### Incoming webhook:
WEBHOOK = ""


