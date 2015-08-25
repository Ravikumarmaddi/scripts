#!/bin/bash

# usage function
function usage() {
  echo "Usage: `basename $0` [--launch|--help] [dbname]"
}

# check params and load variables
USERDB=DBInstance
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
      USERDB=$o
    fi
  done
fi

# create template
USERDATA=`mktemp`
cp ~/scripts/template.datatier.user-data.sh $USERDATA
sed -i s/DBInstance/${USERDB}/ $USERDATA

# specify database details
DBNAME=$USERDB
DBIID=`echo $USERDB | awk '{print tolower($0)}'`
DBSIZE=5
DBTYPE="db.t2.micro"
PLATFORM="MySQL"
USER=`echo $USERDB | awk '{print tolower($0)}'`
PASSWD=`echo $USERDB | awk '{print tolower($0)}'`
TIER="Database"
HOSTGROUP="DatabaseTierNetworkAccess"
VPCGROUPS='"sg-4dc26f29" "sg-2056fd44"'
REGION="us-west-2"
RETPERIOD=0

# construct command
if [[ $LAUNCH == TRUE ]]; then
  COMMAND="aws rds create-db-instance"
  echo "Creating instance..."
else
  COMMAND="aws rds create-db-instance --dry-run"
  echo "Executing dry run..."
fi


///need to finish this

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

