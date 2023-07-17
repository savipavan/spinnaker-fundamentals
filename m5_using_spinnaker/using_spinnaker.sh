DOCKER_REGISTRY_SERVER="https://index.docker.io/v1/"
DOCKER_USER=""
DOCKER_PASSWORD=""

kubectl create secret -n infra docker-registry regcred \
  --docker-server=$DOCKER_REGISTRY_SERVER \
  --docker-username=$DOCKER_USER \
  --docker-password=$DOCKER_PASSWORD

### Expressions
## for staging pipeline
build_number = "${ #stage('Jenkins build')['context']['buildNumber']}"
image_tag = "${ #stage('Jenkins build')['context']['Tag']}"

## for production pipeline
image_tag = "${ trigger.parentExecution.stages.?[name == 'Jenkins build'][0].context.Tag }"