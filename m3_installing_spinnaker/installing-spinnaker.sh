################ Installing Halyard

### Making config directory
mkdir ~/.hal

### Starting Halyard container
docker run -p 8084:8084 -p 9000:9000 --name halyard  -d \
    -v ~/.hal:/home/spinnaker/.hal \
    -v ~/.kube:/home/spinnaker/.kube \
    us-docker.pkg.dev/spinnaker-community/docker/halyard:1.54.0

### execute into halyard
docker exec -it halyard bash

### Stop the halyard container
docker stop halyard

### restart the halyard container
docker restart halyard

### Update halyard
docker pull us-docker.pkg.dev/spinnaker-community/docker/halyard:1.54.0


################ Cloud providers

### Enable kubernetes provider
hal config provider kubernetes enable

### Create spinnaker namespace
kubectl create ns spinnaker

### Create spin user role
kubectl apply -f rbac/spin-user-role.yaml

### Create spin user service account
kubectl apply -f rbac/spin-user-sa.yaml

### Create spin user role binding
kubectl apply -f rbac/spin-user-role-binding.yaml

### Get the current context
CONTEXT=$(kubectl config current-context)

### Get the spinnaker-user's token
TOKEN=$(kubectl get secret --context $CONTEXT \
   -n spinnaker spinnaker-user-secret \
   -o jsonpath='{.data.token}' | base64 --decode)

### Set the credentials
kubectl config set-credentials ${CONTEXT}-token-user --token $TOKEN

kubectl config set-context $CONTEXT --user ${CONTEXT}-token-user

### Get the pods
kubectl get pods

### Add the tools cluster configuration
export ACCOUNT="tools-cluster"
hal config provider kubernetes account add $ACCOUNT --context $CONTEXT


################ Setting Installation type and storage

### Set the installation type
hal config deploy edit --type distributed --account-name $ACCOUNT

### Set the external storage s3 configuration
YOUR_ACCESS_KEY_ID=""
REGION="us-east-1"
hal config storage s3 edit \
    --access-key-id $YOUR_ACCESS_KEY_ID \
    --secret-access-key \
    --bucket panda-spinnaker-bucket \
    --region $REGION --path-style-access

hal config storage edit --type s3


################ Deploying Spinnaker

### Get all versions
hal version list

### Set the Spinnaker version to latest
export VERSION="1.29.0"
hal config version edit --version $VERSION

### Deploy spinnaker
hal deploy apply


################ Exposing Spinnaker

### Exposing using halyard
kubectl port-forward -n spinnaker svc/spin-deck 9000
kubectl port-forward -n spinnaker svc/spin-gate 8084


### Deploy ingress using helm
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm repo update ingress-nginx

helm upgrade --install ingress ingress-nginx/ingress-nginx --namespace infra --version 4.4.0


### Create the ingress object
kubectl apply -n spinnaker -f ingress/spinnaker.yaml

### get ingress object
kubectl get ingress -n spinnaker spinnaker-ingress

### Add the host entry tp /etc/hosts
sudo vi /etc/hosts

20.204.225.141  spinnaker.internal


