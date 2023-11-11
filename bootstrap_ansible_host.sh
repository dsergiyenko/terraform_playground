#!/bin/bash
echo '${private_key}' > /home/centos/.ssh/id_rsa
echo '${public_key}' > /home/centos/.ssh/id_rsa.pub
echo '${public_key}' >> /home/centos/.ssh/authorized_keys
chmod 600 /home/centos/.ssh/id_rsa
chmod 600 /home/centos/.ssh/authorized_keys
chmod 644 /home/centos/.ssh/id_rsa.pub
sudo chown -R centos:centos /home/centos/.ssh
sudo yum -y install epel-release
sudo yum -y install ansible
cd /home/centos
wget https://11459ansible.object.pscloud.io/ansible.zip
unzip ansible.zip
cd ansible
