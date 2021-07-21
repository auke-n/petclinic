#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

yum update -y

#Create a SWAP-file
dd if=/dev/zero of=/swapfile count=2048 bs=1MiB
chmod 600 /swapfile
mkswap /swapfile
swapon  /swapfile
echo "/swapfile   swap    swap    sw  0   0" >> /etc/fstab
mount -a

#Install Ansible

amazon-linux-extras install ansible2

#Install Ansible roles: java, jenkins, docker, pip, git

ansible-galaxy install geerlingguy.jenkins
ansible-galaxy install geerlingguy.java
ansible-galaxy install geerlingguy.pip
#ansible-galaxy install geerlingguy.docker
ansible-galaxy install geerlingguy.git

cd ~/.ansible/roles
ansible-galaxy init docker

echo "
    - name: Update all packages
      yum:
        name: '*'
        state: latest
        update_only: yes

    - name: Ensure a list of yum packages are installed
      yum:
        name: '{{ packages }}'
        state: latest
        update_cache: yes
      vars:
        packages:
        - python-pip
        - yum-utils
        - device-mapper-persistent-data
        - lvm2
        - amazon-linux-extras

    - name: Add extras repository
      shell: yum-config-manager --enable extras

    - name: Enable Some packages from amazon-linux-extras packages
      shell: 'amazon-linux-extras enable python3.8 ansible2 docker'

    - name: clean yum metadata cache
      command: yum clean metadata
      args:
        warn: false

    - name: Ensure a list of yum packages are installed
      yum:
        name: '{{ packages }}'
        state: latest
        update_cache: yes
      vars:
        packages:
        - python3.8
        - ansible
        - docker

    - name: Enable Docker CE service at startup
      service:
        name: docker
        state: started
        enabled: yes

    - name: Upgrade pip3
      shell: 'python3.8 -m pip install pip --upgrade'

    - name: Ensure Python pip packages are installed
      pip:
        name: '{{ packages }}'
        executable: /usr/local/bin/pip3.8
      vars:
        packages:
        - boto
        - boto3
        - docker-compose" > ~/.ansible/roles/docker/tasks/main.yml

echo "---
- hosts: localhost
  become: true
  vars:
    java_packages:
       - java-1.8.0-openjdk
    pip_install_packages:
       - name: docker
  roles:
    - role: geerlingguy.java
    - role: geerlingguy.jenkins
    - role: geerlingguy.git
    - role: geerlingguy.pip
    - role: docker
" > site.yml

#Run playbook
ansible-playbook site.yml

sed -i 's/JENKINS_PORT=8080/JENKINS_PORT=8082/g' /etc/sysconfig/jenkins
systemctl restart jenkins