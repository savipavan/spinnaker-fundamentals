### Setting up notification
## enable slack
hal config notification slack enable

## configure slack
INCOMING_WEBHOOK="https://hooks.slack.com/services/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"
SPINNAKER_BOT="spinnaker"

hal config notification slack edit --bot-name $SPINNAKER_BOT \
--force-use-incoming-webhook --token


## Backup the spinnaker
hal backup create

## Update spinnaker
# List the Spinnaker versions
hal version list

# Set the Spinnaker version
hal config version edit --version 1.29.2

# deploy the spinnaker
hal deploy apply

## Restore the backup
hal backup restore --backup-path halyard-2023-02-13_22-42-10-613Z.tar

## get image id
kubectl get pods -n spinnaker -o jsonpath="{.items[*].spec.containers[*].image}" |tr -s '[[:space:]]' '\n' |sort |uniq -c


### Setup Plugin
## add a repository
hal plugins repository add spinnaker-plugin-examples \
    --url=https://raw.githubusercontent.com/spinnaker-plugin-examples/examplePluginRepository/master/plugins.json

## Enable random wire plugin
hal plugins add Armory.RandomWaitPlugin --extensions=armory.randomWaitStage \
--version=1.1.4 --enabled=true

## List repository
hal plugins repository list

## edit repository
hal plugins repository edit

## delete a repository

hal plugins repository delete <repo-name>

### Caching & Scaling
kubectl scale --replicas=3 -n spinnaker deployment/spin-clouddriver



### Post man

auth_url = "https://accounts.google.com/o/oauth2/auth"
access_token_url = "https://accounts.google.com/o/oauth2/token"

postman_redirect_url = "https://oauth.pstmn.io/v1/callback"


### Pipelines template

## install spin
curl -LO https://storage.googleapis.com/spinnaker-artifacts/spin/$(curl -s https://storage.googleapis.com/spinnaker-artifacts/spin/latest)/darwin/amd64/spin
chmod +x spin
sudo mv spin /usr/local/bin/spin

## create .spin directory
mkdir ~/.spin

## create spin cli config file
vi ~/.spin/config

## Get spin application
## enable
hal config features edit --pipeline-templates true

## save template
spin pipeline-templates save --file template/template.txt