### Switch to new deployment
hal config --set-current-deployment stage

## Call a secret in halconfig
encrypted:s3!r:us-east-1!b:panda-demo-spinnaker-bucket!f:s3-secrets.yaml!k:aws_s3.access_key
encrypted:s3!r:us-east-1!b:panda-demo-spinnaker-bucket!f:s3-secrets.yaml!k:aws_s3.secret
encryptedFile:s3!r:us-east-1!b:panda-demo-spinnaker-bucket!f:s3-secrets.yaml

### Apply ingress
kubectl apply -n spinnaker -f ingress/spinnaker.yaml


### Install cert-manager

## Add and update the helm repo
helm repo add jetstack https://charts.jetstack.io
helm repo update jetstack

## Install cert-manager
helm upgrade --install cert-manager jetstack/cert-manager --namespace infra --version v1.10.0 -f cert-manager/values.yaml

## create clusterissuer
kubectl apply -n infra -f cert-manager/http-issuer.yaml

### Configure the gate and deck url
hal config security ui edit \
    --override-base-url https://spinnaker.panda-labs.online

hal config security api edit \
    --override-base-url https://spinnaker-api.panda-labs.online

hal deploy apply

### Authentication
client_id=""
client_secret=""

### configure google oauth
hal config security authn oauth2 edit --provider google --client-id ${client_id} --client-secret ${client_secret}

hal config security authn oauth2 enable

### redirect uri mismatch
hal config security authn oauth2 edit --pre-established-redirect-uri https://spinnaker-api.panda-labs.online/login

### Authorization
hal config security authz enable

hal config security authz file

hal config security authz file edit --file-path ~/.hal/role.yaml

##Get fiat service
kubectl get pods -n spinnaker | grep fiat

### Jenkins CI

## Install Jenkins

## Add & update the jenkins helm chart
helm repo add jenkins https://charts.jenkins.io
helm repo update jenkins

## Deploy jenkins
helm upgrade --install jenkins jenkins/jenkins --namespace infra --version 4.3.0 -f jenkins/values.yaml


## enable jenkins
hal config ci jenkins enable

## configure jenkins master
BASEURL="http://jenkins.infra:8080"
USERNAME=""
PASSWORD=""

hal config ci jenkins master add my-jenkins-master \
    --address $BASEURL \
    --username $USERNAME \
    --password $PASSWORD

### csrf enable
hal config ci jenkins master edit my-jenkins-master --csrf true

### enable github artifact
hal config artifact gitrepo enable

### add github artifact settings
TOKEN=""
GITHUB_ACCOUNT="shubhasish"
echo $TOKEN > token.txt
hal config artifact gitrepo account add $GITHUB_ACCOUNT \
    --token-file token.txt

## triggers



