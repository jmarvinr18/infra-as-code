#!/bin/bash

# Configuration
JENKINS_URL="https://jenkins.xctuality.com"         # e.g., http://localhost:8080
JOB_NAME="METAFARMS/job/devops-utilities/job/Stop%20Instance"                      # e.g., my-job
USER="user"                          # Jenkins username
API_TOKEN="#############"                    # Jenkins API token

# Trigger the job

/usr/bin/curl -X POST "${JENKINS_URL}/job/${JOB_NAME}/build" \
  --user "${USER}:${API_TOKEN}"