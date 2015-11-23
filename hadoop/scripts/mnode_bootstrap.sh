#!/bin/bash

# ensure the system is up to date
yum update -y

# install some stuff
yum install bind-utils nc telnet nmap ntp sysstat httpd zip unzip wget -y

# install system stress tool
curl "http://dl.fedoraproject.org/pub/epel/6/x86_64/stress-1.0.4-4.el6.x86_64.rpm" -o stress-1.0.4-4.el6.x86_64.rpm
yum install -y stress-1.0.4-4.el6.x86_64.rpm

# install the aws command line
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# install ambari and hdp dependencies
  # set open file limit
  echo "fs.file-max = 12288" >> /etc/sysctl.conf; sysctl -p
  # disable hugepages
  echo never > /sys/kernel/mm/transparent_hugepage/enabled
  echo never > /sys/kernel/mm/transparent_hugepage/defrag
  # enable some system swap
  mkdir /var/swap; touch /var/swap/swapfile; chown root:root /var/swap/swapfile; chmod 600 /var/swap/swapfile
  dd if=/dev/zero of=/var/swap/swapfile bs=1014 count=2097152
  mkswap /var/swap/swapfile; swapon /var/swap/swapfile
  echo "/var/swap/swapfile      swap    swap    defaults        0 0" >> /etc/fstab
  # selinux permissive mode
  setenforce 0 # needed for Ambari setup to run; not persistent
  # set up ntp; default configuration will do
  systemctl enable ntpd.service; ntpdate pool.ntp.org; systemctl start ntpd.service
  # grab the java RPM from S3 and install
  /usr/local/bin/aws s3 cp s3://kpedsotherbucket/packages/jre-7u45-linux-x64.rpm jre-7u45-linux-x64.rpm
  yum install jre-7u45-linux-x64.rpm -y
  # grab the Ambari repo
  wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.1.2/ambari.repo -O /etc/yum.repos.d/ambari.repo
 
# clean up
rm -rf awscli-bundle jre-7u45-linux-x64.rpm

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
