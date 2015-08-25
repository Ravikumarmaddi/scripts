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

# specify database details
DBNAME=$USERDB
DBIID=`echo $USERDB | awk '{print tolower($0)}'`
DBSIZE=5
DBTYPE="db.t2.micro"
PLATFORM="MySQL"
USER=`echo $USERDB | awk '{print tolower($0)}'`
PASSWD=`echo $USERDB | awk '{print tolower($0)}'`
TIER="Database"
GROUP="sg-b018b2d4"
REGION="us-west-2"
RETPERIOD=0

# construct command
if [[ $LAUNCH == TRUE ]]; then
  COMMAND="aws rds create-db-instance"
  echo "Creating instance..."
else
  COMMAND="echo aws rds create-db-instance"
fi

# construct parameters
EXEC="--db-name $DBNAME --db-instance-identifier $DBIID --allocated-storage $DBSIZE --db-instance-class $DBTYPE --engine $PLATFORM --master-username $USER --master-user-password $PASSWD --vpc-security-group-ids $GROUP --backup-retention-period $RETPERIOD --no-publicly-accessible"

# construct tags
TAGS="--tags Key=Name,Value=${DBNAME} Key=Platform,Value=${PLATFORM} Key=Tier,Value=${TIER}"

# execute launch command with parameters
#echo $COMMAND $EXEC $TAGS
$COMMAND $EXEC $TAGS 

