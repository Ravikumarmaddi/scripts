#!/bin/bash

# usage function
function usage() {
  echo "Usage: `basename $0` [--launch|--help] [hostname]"
}

# check params and load variables
if [[ $# -gt 2 ]]; then
  usage
  exit 
else
  for o in $@; do
    if [[ $o == "--launch" ]]; then
      LAUNCH=TRUE
    elif [[ $o == "--help" ]]; then
      usage
      exit
    else
      USERHOST=$o
    fi
  done
fi

# create template
cp ~/scripts/template.webtier.user-data.sh ~/scripts/${USERHOST}.webtier.user-data.sh
sed -i s/WebTierASinstance/${USERHOST}/g ~/scripts/${USERHOST}.webtier.user-data.sh

# specify machine details
IMAGE="ami-c7d092f7"
SCRIPT="file://~/scripts/${USERHOST}.webtier.user-data.sh"
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
rm -f $OUT

echo "Tagging instance..."
aws ec2 create-tags --resources $IID --tags Key=Name,Value=$USERHOST Key=Platform,Value=$PLATFORM Key=Tier,Value=$TIER

echo -n "Monitoring instance... "
echo -n "HighCPU... "
aws cloudwatch put-metric-alarm \
--alarm-name $USERHOST.HighCPU \
--metric-name CPUUtilization \
--namespace AWS/EC2 \
--statistic Average \
--period 300 \
--threshold 80 \
--comparison-operator GreaterThanThreshold \
--dimensions Name=InstanceID,Value=$IID \
--evaluation-periods 1 \
--unit Percent \
--alarm-actions arn:aws:sns:us-west-2:035296091979:administrator

echo -n "HighOutboundTraffic... "
aws cloudwatch put-metric-alarm \
--alarm-name $USERHOST.HighOutboundTraffic \
--metric-name NetworkOut \
--namespace AWS/EC2 \
--statistic Average \
--period 300 \
--threshold 50000000 \
--comparison-operator GreaterThanThreshold \
--dimensions Name=InstanceID,Value=$IID \
--evaluation-periods 1 \
--unit Bytes \
--alarm-actions arn:aws:sns:us-west-2:035296091979:administrator

echo -n "StatusCheckFailed... "
aws cloudwatch put-metric-alarm \
--alarm-name $USERHOST.StatusCheckFailed \
--metric-name StatusCheckFailed \
--namespace AWS/EC2 \
--statistic Maximum \
--period 300 \
--threshold 1 \
--comparison-operator GreaterThanOrEqualToThreshold \
--dimensions Name=InstanceID,Value=$IID \
--evaluation-periods 1 \
--unit Count \
--alarm-actions arn:aws:sns:us-west-2:035296091979:administrator

echo

