#!/bin/bash

# set the hostname here, optionally
# USERHOST=

# ensure the system is up to date
yum update -y

# install some stuff
yum install bind-utils nc zip unzip -y

# install system stress tool
curl "http://dl.fedoraproject.org/pub/epel/6/x86_64/stress-1.0.4-4.el6.x86_64.rpm" -o stress-1.0.4-4.el6.x86_64.rpm
yum install -y stress-1.0.4-4.el6.x86_64.rpm

# install the aws command line
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# set the hostname, if specified
if [ -n "$USERHOST" ]; then
  sed -i '1s/^/preserve_hostname: true\n/' /etc/cloud/cloud.cfg
  hostname $USERHOST
  echo $USERHOST > /etc/hostname
fi

# set the hosts file for easy reference
#
# short, long and user names for public IP
SHOST=`curl -s http://169.254.169.254/latest/meta-data/public-hostname/ | awk -F . '{print $1}'`
LHOST=`curl -s http://169.254.169.254/latest/meta-data/public-hostname/`
IPADDR=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4/`
echo $IPADDR $LHOST $SHOST $HOSTNAME >> /etc/hosts
#
# short, long and user names for local/private IP
SHOST=`curl -s http://169.254.169.254/latest/meta-data/local-hostname/ | awk -F . '{print $1}'`
LHOST=`curl -s http://169.254.169.254/latest/meta-data/local-hostname/`
IPADDR=`curl -s http://169.254.169.254/latest/meta-data/local-ipv4/`
echo $IPADDR $LHOST $SHOST $HOSTNAME.local $HOSTNAME.private >> /etc/hosts

# configure iam user and authkey
useradd kpedersen -g kpedersen -d /home/kpedersen -s /bin/bash
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
