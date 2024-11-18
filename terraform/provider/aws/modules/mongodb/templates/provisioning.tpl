#!/bin/bash

sudo apt update -y
sudo apt upgrade -y

## 6.0
curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/mongodb-6.gpg
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

## setup mongodb security keys
sudo mkdir -p /opt/mongodb/keys/
echo "${mongo_key}" > /opt/mongodb/keys/mongo-key

sudo apt update -y
sudo apt install mongodb-org -y

sudo systemctl start mongod
sudo systemctl enable --now mongod

## change own to mongodb
sudo chmod 400 /opt/mongodb/keys/mongo-key
sudo chown -R mongodb:mongodb /opt/mongodb

## set ips and hostnames in /etc/hosts
cat << EOF > confighosts.py
#!/usr/bin/python
from subprocess import run

node_host = "${nodes_hosts}".split(',')
node_ip = "${nodes_ips}".split(',')

for idx, ip in enumerate(node_ip):
    run( "echo "+str(ip)+" "+node_host[idx]+" >> /etc/hosts", shell=True )
EOF
chmod 755 confighosts.py
python3 confighosts.py

## set hostname
sudo hostnamectl set-hostname ${domain_name}

sudo sed -i "s~#security:*~security:\\n    authorization: enabled\\n    keyFile:  /opt/mongodb/keys/mongo-key~g" /etc/mongod.conf

sudo systemctl restart mongod

if [[ "${domain_name}" == "${primary_node}" ]]; then echo -e "use admin; \n db.createUser({ user: '${root_user}', pwd: '${root_pass}', roles: [{ role: 'root', db: 'admin'}]}) \n db.createUser({user: '${admin_user}', pwd: '${admin_pass}', roles: [{ role: 'userAdminAnyDatabase', db: 'admin' }, 'readWriteAnyDatabase' ]})" | mongosh; fi

sudo systemctl restart mongod

######################
## for replica sets
######################

# for mongod configuration (shard server) : updating replication > replSetName 
sudo sed -i "s/#replication:*/replication:\\n    replSetName: ${repl_name}/g" /etc/mongod.conf

# for mongod configuration (shard server) : updating net > bindIp
sudo sed -i "s/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g" /etc/mongod.conf


sudo systemctl restart mongod

sleep 10

if [ ${domain_name} == ${primary_node} ]
then

mongosh -u ${root_user} -p ${root_pass} --authenticationDatabase admin <<EOF
rs.initiate()
EOF

sleep 10

mongosh -u ${root_user} -p ${root_pass} --authenticationDatabase admin <<EOF
rs.add("${secondary_node1}:27017")
EOF

sleep 10

mongosh -u ${root_user} -p ${root_pass} --authenticationDatabase admin <<EOF
rs.add("${secondary_node2}:27017")
EOF

fi

sleep 20


########################
## end for replica sets
########################