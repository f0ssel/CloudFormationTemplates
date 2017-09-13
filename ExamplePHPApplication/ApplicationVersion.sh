#!/bin/bash
# This must be located in the root of the application repo
# The first arguement should be the name of the version you want to create
# For example: "v2" or "64" or "beta"
# Versions must be unique, it will not overwrite existing artifacts in s3
#
# Usage: "sh ApplicationVersion.sh [versionLabel]"
#
# Variables you change

APPNAME='Sample-PHP'
BUCKET='sample-php-0917'
KEY='sample-application'

# Code you don't need to change
VERSION=$1
echo "Creating application version '$VERSION' for application '$APPNAME'"

if [[ $(aws s3 ls s3://$BUCKET/$KEY-$VERSION.zip) ]]; then
  echo "ERROR: The artifact s3://$BUCKET/$KEY-$VERSION.zip already exists, use a unique version"
  exit 1
fi

echo 'Creating artifact...'
zip -r artifact.zip ./* -x "$0"
echo 'Copying artifact to s3...'
aws s3 cp artifact.zip s3://$BUCKET/$KEY-$VERSION.zip
echo 'Cleaning up artifact... '
rm artifact.zip
echo 'Creating new Elastic Beanstalk Application Version...'
aws elasticbeanstalk create-application-version --application-name $APPNAME --version-label $VERSION --source-bundle S3Bucket=$BUCKET,S3Key=$KEY-$VERSION.zip
echo "FINISHED: Successfully created Elastic Beanstalk Application Version : $VERSION"
