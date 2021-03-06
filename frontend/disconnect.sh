#!/usr/bin/env bash

# logout of whererver
oc logout

# login to acm to patch
oc login -u ${OC_USER} -p ${OC_PASSWORD} --server=https://api.summit-aws-acm.openshift.redhatkeynote.com:6443 --insecure-skip-tls-verify=true
oc patch cluster -n london london --type=json -p='[{"op": "remove", "path": "/metadata/labels/app"}]'
oc logout


# login to lnd to remove the items
oc login -u ${OC_USER} -p ${OC_PASSWORD} api.summit-aws-lnd1.openshift.redhatkeynote.com:6443 --insecure-skip-tls-verify=true

printf "\n\n######## disconnect from ha proxy ########\n"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT=${PROJECT:-frontend}

oc project ${PROJECT} 2> /dev/null || oc new-project ${PROJECT}


oc process -f "${DIR}/phone-route.yml" | oc delete -f -
oc rollout latest dc/phone-ui
oc rollout latest dc/phone-server
