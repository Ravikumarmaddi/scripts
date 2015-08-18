#!/bin/bash

# todo
# parametize the hostname

# dry run by default
for o in "$@"; do
  if [[ $o == "--launch" ]]; then
    LAUNCH=TRUE
  fi
done

# specify machine details
IMAGE="ami-c7d092f7"
HOSTNAME=
SCRIPT="file://~/scripts/template.webtier.user-data.sh"
PLATFORM="CentOS7"
TIER="Web"
TYPE="t2.micro"
GROUP="WebTierNetworkAccess"
ROLE="S3ReadOnlyAccess"
REGION="us-west-2"
KEY="kpedersen_aws_rsa"

# construct command
if [[ $LAUNCH == TRUE ]]; then
  COMMAND="aws ec2 run-instances"
  echo "Launching instance..."
else
  COMMAND="aws ec2 run-instances --dry-run"
  echo "Executing dry run..."
fi

# construct parameters
EXEC="--image-id $IMAGE --key-name $KEY --user-data $SCRIPT --instance-type $TYPE --security-groups $GROUP --iam-instance-profile Name=$ROLE --region $REGION"

# execute launch command with parameters
OUT=`mktemp`
echo $COMMAND $EXEC
$COMMAND $EXEC | tee $OUT

# parse output and tag the new instance
IID=`cat $OUT | grep InstanceId | awk '{print $2}' | sed s/\"//g | sed s/,//g`
echo "Tagging instance..."
aws ec2 create-tags --resources $IID --tags Key=Name,Value=$HOSTNAME Key=Platform,Value=$PLATFORM Key=Tier,Value=$TIER
rm -f $OUT
