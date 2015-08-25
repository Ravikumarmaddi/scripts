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
GROUP="DatabaseTierNetworkAccess"
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
EXEC="--db-name $DBNAME --db-instance-identifier $DBIID --allocated-storage $DBSIZE --db-instance-class $DBTYPE --engine $PLATFORM --master-username $USER --master-user-password $PASSWD --db-security-groups $GROUP --vpc-security-group-ids $VPCGROUPS --backup-retention-period $RETPERIOD --no-publicly-accessible"

# execute launch command with parameters
OUT=`mktemp`
echo $COMMAND $EXEC
$COMMAND $EXEC | tee $OUT

# grab the instance id
#IID=`cat $OUT | grep InstanceId | awk '{print $2}' | sed s/\"//g | sed s/,//g`

# tag the instance
#echo "Tagging instance..."
#aws ec2 create-tags --resources $IID --tags Key=Name,Value=$USERDB Key=Platform,Value=$PLATFORM Key=Tier,Value=$TIER

# monitor the instance

# clean up temp files
rm -f $OUT 

