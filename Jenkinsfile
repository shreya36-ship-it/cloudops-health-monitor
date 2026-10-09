pipeline {
    agent any

    parameters {
        string(name: 'EC2_1_IP', defaultValue: '', description: 'Public IP of EC2 instance 1')
        string(name: 'EC2_2_IP', defaultValue: '', description: 'Public IP of EC2 instance 2')
    }

    environment {
        REGISTRY       = 'ghcr.io'
        IMAGE_NAME     = 'ghcr.io/shreya36-ship-it/cloudops-health-monitor'
        IMAGE_TAG      = "${env.BUILD_NUMBER}"
        CONTAINER_NAME = 'cloudops-monitor'
        SSH_USER       = 'ec2-user'
    }

    stages {
        stage('Clone') {
            steps {
                git branch: 'main', url: 'https://github.com/shreya36-ship-it/cloudops-health-monitor.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                bat 'docker build -t %IMAGE_NAME%:%IMAGE_TAG% -t %IMAGE_NAME%:latest .'
            }
        }

        stage('Push to GHCR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'ghcr-creds',
                                                  usernameVariable: 'GHCR_USER',
                                                  passwordVariable: 'GHCR_TOKEN')]) {
                    bat '''
                        echo %GHCR_TOKEN%| docker login %REGISTRY% -u %GHCR_USER% --password-stdin
                        docker push %IMAGE_NAME%:%IMAGE_TAG%
                        docker push %IMAGE_NAME%:latest
                        docker logout %REGISTRY%
                    '''
                }
            }
        }

        stage('Deploy to EC2-1') {
            steps {
                deployTo(params.EC2_1_IP)
            }
        }

        stage('Deploy to EC2-2') {
            steps {
                deployTo(params.EC2_2_IP)
            }
        }

        stage('Health Check') {
            steps {
                bat """
                    ping -n 11 127.0.0.1 > nul
                    curl.exe -fsS --retry 5 --retry-delay 5 http://${params.EC2_1_IP}:5000/health || exit /b 1
                    curl.exe -fsS --retry 5 --retry-delay 5 http://${params.EC2_2_IP}:5000/health || exit /b 1
                """
            }
        }
    }

    post {
        success { echo 'Deployment successful: both instances healthy.' }
        failure { echo 'Deployment failed. Check the stage logs above.' }
    }
}


def deployTo(String host) {
    sshagent(credentials: ['ec2-ssh-key']) {
        bat "ssh -o StrictHostKeyChecking=no %SSH_USER%@${host} \"docker pull %IMAGE_NAME%:%IMAGE_TAG% && docker rm -f %CONTAINER_NAME% || true && docker run -d --name %CONTAINER_NAME% --restart unless-stopped -p 5000:5000 %IMAGE_NAME%:%IMAGE_TAG%\""
    }
}
