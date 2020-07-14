#!/bin/bash
DOCKER_LOGIN=$(aws ecr get-login --region "$1" --no-include-email)
DOCKER_PASSWORD=$(echo "$DOCKER_LOGIN" | cut --delimiter=" " --fields=6 -)
DOCKER_AUTH_TOKEN=$(echo -n "AWS:$DOCKER_PASSWORD" | base64 --wrap=0)
jq -n "{ \"auths\": { \"$2\": { \"auth\": \"$DOCKER_AUTH_TOKEN\" }}, \"HttpHeaders\": { \"User-Agent\": \"Docker-Client/19.03.6-ce (linux)\" }}" > config.json
aws s3 cp config.json s3://"$3"/config.json