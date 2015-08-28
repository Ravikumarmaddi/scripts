#!/bin/bash

# usage function
function usage() {
  echo "Usage: `basename $0` [--launch|--help] [hostname] [dbconn]"
}

# check params and load variables
if [[ $# -gt 3 ]]; then
  usage
  exit
else
  for o in $@; do
    if [[ $o == "--launch" ]]; then
      LAUNCH=TRUE
    elif [[ $o == "--help" ]]; then
      usage
      exit
    elif [[ -n "$USERHOST" ]]; then
      DBCONN=$o
    else
      USERHOST=$o
    fi
  done
fi
if [[ -n $USERHOST ]]; then
  USERHOST=WebInstance
fi

# create template
USERDATA=`mktemp`
cp ~/scripts/template.webtier.user-data.sh $USERDATA
sed -i s/WebInstance/${USERHOST}/ $USERDATA
sed -i s/testdb12/${DBCONN}/g $USERDATA

# specify machine details
IMAGE="ami-c7d092f7"
SCRIPT="file://$USERDATA"
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

# grab the instance id
IID=`cat $OUT | grep InstanceId | awk '{print $2}' | sed s/\"//g | sed s/,//g`

# tag the instance
echo "Tagging instance..."
aws ec2 create-tags --resources $IID --tags Key=Name,Value=$USERHOST Key=Platform,Value=$PLATFORM Key=Tier,Value=$TIER

# remove the EBS volume on termination
echo "Configuring EBS volume to delete on termination..."
sleep 10
aws ec2 modify-instance-attribute --instance-id $IID --block-device-mappings "[{\"DeviceName\": \"/dev/sda1\",\"Ebs\":{\"DeleteOnTermination\":true}}]"

# register with ELB
echo "Registering instance with load balancer..."
aws elb register-instances-with-load-balancer --load-balancer-name ExternalLB --instances $IID

# monitor the instance
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

# clean up temp files
rm -f $OUT $USERDATA
