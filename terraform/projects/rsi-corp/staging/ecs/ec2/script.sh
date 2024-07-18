#!/bin/bash

cat /dev/null > ./ansible/inventory.ini
echo [webserver] >> ./ansible/inventory.ini
echo ${self.public_ip} >> ./ansible/inventory.ini