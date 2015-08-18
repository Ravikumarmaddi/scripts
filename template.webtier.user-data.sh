#!/bin/bash

# set the hostname here, optionally
# USERHOST=

# ensure the system is up to date
yum update -y

# install required packages
yum install httpd unzip -y

# install the aws command line (required for S3 access)
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
rm -rf awscli-bundle

# clean up
rm -rf awscli-bundle
rm -rf /var/www/html/*

# populate web root
aws s3 cp --recursive s3://kpedsawsbucket/html/ /var/www/html
chmod 644 /var/www/html/*

# configure web service to run
chkconfig httpd on
service httpd start

# set the hostname, if specified
if [ -n "$USERHOST" ]; then
  sed -i '1s/^/preserve_hostname: true\n/' /etc/cloud/cloud.cfg
  hostname $USERHOST
  echo $USERHOST > /etc/hostname
fi

# set the hosts file for easy reference
#
# short, long and user names for public IP
SHOST=`curl http://169.254.169.254/latest/meta-data/public-hostname/ | awk -F . '{print $1}'`
LHOST=`curl http://169.254.169.254/latest/meta-data/public-hostname/`
IPADDR=`curl http://169.254.169.254/latest/meta-data/public-ipv4/`
echo $IPADDR $LHOST $SHOST $HOSTNAME >> /etc/hosts
#
# short, long and user names for local/private IP
SHOST=`curl http://169.254.169.254/latest/meta-data/local-hostname/ | awk -F . '{print $1}'`
LHOST=`curl http://169.254.169.254/latest/meta-data/local-hostname/`
IPADDR=`curl http://169.254.169.254/latest/meta-data/local-ipv4/`
echo $IPADDR $LHOST $SHOST $HOSTNAME.local $HOSTNAME.private >> /etc/hosts

# configure iam user/key and sudoers
useradd kpedersen -d /home/kpedersen -s /bin/bash
usermod -G wheel,adm kpedersen
mkdir -p /home/kpedersen/.ssh
curl -s "http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key/" -o /home/kpedersen/.ssh/authorized_keys
chmod 700 /home/kpedersen/.ssh
chmod 600 /home/kpedersen/.ssh/authorized_keys
chown -R kpedersen:kpedersen /home/kpedersen/.ssh
sed -i s/centos/kpedersen/g /etc/sudoers.d/*

# clean up bash history
cat /dev/null > /root/.bash_history
cat /dev/null > /home/centos/.bash_history

