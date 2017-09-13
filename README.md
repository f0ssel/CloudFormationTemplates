# FreelanceInfrastructure

# Table of Contents

### General

- [What is in this repository?](#what-is-in-this-repository)
- [How do I deploy a new stack or update a current stack?](#how-do-i-deploy-a-new-stack-or-update-a-current-stack)

### Elastic Beanstalk

- [How do I update my Elastic Beanstalk application?](#how-do-i-update-my-elastic-beanstalk-application)

### Jumpbox

- [How do I ssh into my ec2 instances in private subnets from a jumpbox?](#how-do-i-ssh-into-my-ec2-instances-in-private-subnets-from-a-jumpbox)

### VPC

- [How do I expand the number of Availability Zones in my VPC?](#how-do-i-expand-the-number-of-availability-zones-in-my-vpc)

# General

## What is in this repository?

This repository contains CloudFormation templates, parameter configuration files, and the scripts to deploy these templates. CloudFormation is a tool provided by AWS that allows you define your AWS resources in code so that it is clear, reproduceable, and editable. When you create a set of AWS resources using CloudFormation it is called a stack. CloudFormation validates changes to the stack during deployments and has built in rollback for when invalid changes are made to the environment. Parameters are configuration files where you can pass in value that can be easily changed or copied and are fed into the CloudFormation templates at deploy time. There can be many stacks made that all utilize the same Template and simple have different parameter files that configure each stack. Bash scripts are included that will combine the parameters file specified with a template and utilize the AWS CLI to create and update stacks.

## How do I deploy a new stack or update a current stack?

1. Stacks are created and updated using the DeployStack.sh script in the root of this repository. This script takes in the keys defined in a JSON file (Usually located inside the "Stacks" folder) that defines Name, TemplatePath, Region, and Parameters of the CloudFormation Stack. **You must be in the root directory of this repository to run this script.**

To run:

```sh DeployStack.sh Stacks/example-stack.json```

Where the `example-stack.json` would look something like:

```
{
  "Name": "Example-Stack-Name",
  "TemplatePath": "Templates/Examples/Example1.json",
  "Region": "us-east-1",
  "Parameters": [
    {
      "ParameterKey": "VPCId",
      "ParameterValue": "vpc-xxxxxxxx"
    },
    {
      "ParameterKey": "SSHKeyName",
      "ParameterValue": "examplekey"
    },
    {
      "ParameterKey": "PublicSubnets",
      "ParameterValue": "subnet-xxxxxxxx,subnet-xxxxxxxx"
    }
  ]
}
```
# Elastic Beanstalk (EB)

## How do I update my Elastic Beanstalk application?

The way any Elastic Beanstalk environment is updated is by deploying an Application Version to an existing evironment. The included Elastic Beanstalk stacks include a Test and Prod environment. The included "ApplicationVersion.sh" script aid in creating new versions of your application so that deployment is easier. The script creates an artifact from the code repository, uploads it to s3, and creates a new application version in Elastic Beanstalk that references that code artifact. After the application version is in the Elastic Beanstalk console, it's as easy as hitting the "Deploy" button in the console and choosing the application version and environment you would like to deploy to.

The "ApplicationVersion.sh" script takes a single parameter, the version label. This script must live in the root of the application directory and must be run from the same root directory. For example:

`sh ApplicationVersion.sh v6`

After this successfully runs, you will see the new version in the Elastic Beanstalk console, where you can choose to deploy it to your environments. The application environments must already exist, as well as the desired s3 bucket you would like to store your version artifacts in. The "ApplicationVersion.sh" script has variables that must be modified to match your application and s3 bucket. The first few lines are:

```
APPNAME='Sample-PHP'
BUCKET='sample-php-0917'
KEY='sample-application'
```

Where APPNAME is the application name as it reads in the Elastic Beanstalk Console, BUCKET is the name of the s3 bucket you would like to upload the artifacts to, and KEY is the location in the bucket you want to save the artifacts to. A new version will be saved at the path `s3://BUCKET/KEY-VERSION.zip` and this combination must be unique. The script will not overwrite any existing versions by that name and will fail.

# Jumpbox (EC2)

## How do I ssh into my ec2 instances in private subnets from a jumpbox?

The easiest way to accomplish this is to stand up both the Jumpbox and any other Application instances from other stacks with the same SSH Key Pair. Once the jumpbox is stood up and configured with the same SSH Key Pair as the instance you would like to SSH into, you can follow the following steps:

1. Add ssh key on local machine to SSH session:
  `ssh-add /path/to/ssh/key`
2. For Amazon Linux servers, use the `ec2-user` login and for ubuntu use the `ubuntu` login:

  `ssh -At ec2-user@jumpbox-public-ip ssh ec2-user@target-instance-private-ip`

  or

  `ssh -At ubuntu@jumpbox-public-ip ssh ubuntu@target-instance-private-ip`

You should now be connected to the target instance.

# VPC (VPC)

## How do I expand the number of Availability Zones in my VPC?

The addition of another Availability Zone will increase the fault tolerance of your applications by load balancing them over multiple data centers. In the event of losing connectivity to an AZ, you have others that are in the Load Balancer that instances can be created in and take the new traffic load.

Each instance uses a NAT Gateway which runs around $35/month, so for very small environments it may be cost prohibitive to use more than 2 Availability Zones. It is highly recomended that 2 in the minimum number of AZ to be in, but 3 is ideal for high availability.

Expanding AZ's is easy with the included CloudFormation Template, simply update the Parameter "NumberOfAZs" in the stack (Probably named VPC) to the number you would like. Check the number of AZ's for the region you are in, they range from only 2 AZ's to 5 or 6.
