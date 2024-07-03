pipeline {
    agent any

    options {
        skipStagesAfterUnstable()
    }
    environment {
        HOME = '.'
        GITHUB_ORG = credentials("GITHUB_MAIN_ORG")
        GITHUB_PAT = credentials("GITHUB_PAT")
        GITHUB_REPO = "crocoite"
        GITHUB_BRANCH = "SIT"
        GITHUB_USER = "adrian-rsiph"
        SERVICE_PORT = 8082
        CONTAINER_PORT = 8080
        DOCKER_REGISTRY_URL = "https://index.docker.io/v1/"
        DOCKER_REGISTRY_CREDS = credentials('DOCKER_REGISTRY')
        SSH_KEY_ID = 'ssh-agent-pt'
        SSH_USER = 'ubuntu'
        SSH_HOST = '52.77.136.211'         
    }

    stages {
        stage('Clone repository of Crocoite') { 
            steps { 
                script {
                    checkout scm
                    pwd
                }
            }
        }

        stage('Build Image') {
            steps { 
                script {
                    sendBuildNotification('📣', '#439FE0', 'STARTED', env.JOB_NAME, env.BUILD_NUMBER, 'SIT', env.BUILD_URL)
                    app = docker.build("aslitechnologies/crocoite:${env.BUILD_NUMBER}", """
                        --build-arg GITHUB_ORG=${env.GITHUB_ORG} \
                        --build-arg GITHUB_PAT=${env.GITHUB_PAT} \
                        --build-arg GITHUB_REPO=${env.GITHUB_REPO} \
                        --build-arg GITHUB_BRANCH=${env.GITHUB_BRANCH} \
                        --build-arg GITHUB_USER=${env.GITHUB_USER} \
                        --force-rm --no-cache -f ${env.GITHUB_REPO}/Dockerfile .
                    """.trim())
                }
            }
        }

        stage('Test Image') {
            steps {
                script {
                    sh "docker run -p ${env.SERVICE_PORT}:8080 --name crocoite -d --rm aslitechnologies/crocoite:${env.BUILD_NUMBER}"
                    sh 'sleep  3'
                    sh "nc -zv localhost ${env.SERVICE_PORT}"
                    sh 'docker stop crocoite'
                }
            }
        }

        stage('Push Image to Registry') {
            steps {
                script{
                    docker.withRegistry("$DOCKER_REGISTRY_URL", "DOCKER_REGISTRY") {   
                        app.push("sit-build-${env.BUILD_NUMBER}")
                        sh 'docker rmi -f $(docker images -q aslitechnologies/crocoite)'
                    }
                }
            }
        }

        stage("Restart Docker") {
            steps{
                sshagent(["${SSH_KEY_ID}"]){
                    sh "ssh -tt -o StrictHostKeyChecking=no ${SSH_USER}@${SSH_HOST} ./crocoite-docker.sh"                    
                    sh "ssh -tt -o StrictHostKeyChecking=no ${SSH_USER}@${SSH_HOST} docker pull aslitechnologies/crocoite:sit-build-${env.BUILD_NUMBER}"
                    sh "ssh -tt -o StrictHostKeyChecking=no ${SSH_USER}@${SSH_HOST} docker run -d -p 8080:$CONTAINER_PORT  --name crocoite-api --rm aslitechnologies/crocoite:sit-build-${env.BUILD_NUMBER}"
                    sh "ssh -tt -o StrictHostKeyChecking=no ${SSH_USER}@${SSH_HOST} docker system prune -f"                    
                }
            }
        }

    }

    post {
        success {
            script {
                sendBuildNotification('✅', '#36a64f', 'COMPLETED', env.JOB_NAME, env.BUILD_NUMBER, 'SIT', env.BUILD_URL)
            }
        }
        failure {
            script {
                sendBuildNotification('❌', '#ff0000', 'FAILED', env.JOB_NAME, env.BUILD_NUMBER, 'SIT', env.BUILD_URL)
            }
        }
        always {
            script {
                sh "docker system prune -f"
            }
        }
    }
}

def sendApprovalNotification(color, jobName, buildNumber, environment, buildUrl, tagged) {
    def message = "🚦 Build *APPROVAL*: Pipeline ${jobName} | \n *Job* # ${buildNumber} | *Environment*: ${environment} | More Info: ${buildUrl} \n 🗣️ ${tagged} "
    slackSend(channel: 'rsi-builds-approval', color: color, message: message)
}

def sendBuildNotification(emoji, color, status, jobName, buildNumber, environment, buildUrl) {
    def message = "${emoji} Build *${status.toUpperCase()}*: Pipeline ${jobName} | \n *Job* # ${buildNumber} | *Environment*: ${environment} | More Info: ${buildUrl}"
    slackSend(channel: 'rsi-tech-builds', color: color, message: message)
}
