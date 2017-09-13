#!/bin/bash
# This must be located in the root of the infrastructure repo
#
# Usage: "sh DeployStack.sh path/to/stack.json"
#
# Code that doesn't need to be changed

STACKNAME=$(cat $1 | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["Name"];')
TEMPLATEPATH=$(cat $1 | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["TemplatePath"];')
PARAMETERS=$(cat $1 | python -c 'import json,sys;obj=json.load(sys.stdin);print json.dumps(obj["Parameters"]);')
REGION=$(cat $1 | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["Region"];')

aws cloudformation create-stack \
  --stack-name $STACKNAME \
  --template-body file:///$PWD/$TEMPLATEPATH \
  --parameters "$PARAMETERS" \
  --capabilities CAPABILITY_NAMED_IAM \
  --region $REGION ||
  aws cloudformation update-stack \
    --stack-name $STACKNAME \
    --template-body file:///$PWD/$TEMPLATEPATH \
    --parameters "$PARAMETERS" \
    --capabilities CAPABILITY_NAMED_IAM \
    --region $REGION
