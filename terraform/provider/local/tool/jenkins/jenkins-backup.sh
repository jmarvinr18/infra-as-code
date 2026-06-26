#!/bin/bash

backup_date=$(date +"%m-%d-%Y")
file=jenkins_backup_$backup_date.zip

sudo zip -r $file /var/lib/docker/volumes/jenkins-data/_data

aws s3 cp $file s3://jmr-jenkins-backup-bucket/$file

sudo rm $file