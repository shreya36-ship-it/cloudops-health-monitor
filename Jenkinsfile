pipeline {
    agent any

    parameters {
        string(name: 'EC2_1_IP', defaultValue: '', description: 'Public IP of EC2 instance 1 (terraform output ec2_1_public_ip)')
        string(name: 'EC2_2_IP', defaultValue: '', description: 'Public IP of EC2 instance 2 (terraform output ec2_2_public_ip)')
    }

    environment {
        REGISTRY       = 'ghcr.io'
        IMAGE_NAME     = 'ghcr.io/shreya36-ship-it/cloudops-health-monitor'
        IMAGE_TAG      = "${env.BUILD_NUMBER}"
        CONTAINER_NAME = 'cloudops-monitor'
        REPO_URL       = 'https://github.com/shreya36-ship-it/cloudops-health-monitor.git'
        SSH_USER       = 'ec2-user'
    }

    stages {
        stage('Clone') {
            steps {
                git branch: 'main', url: "${REPO_URL}"
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest .'
            }
        }

        stage('Push to GHCR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'ghcr-creds',
                                                  usernameVariable: 'GHCR_USER',
                                                  passwordVariable: 'GHCR_TOKEN')]) {
                    sh '''
                        echo "$GHCR_TOKEN" | docker login ${REGISTRY} -u "$GHCR_USER" --password-stdin
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        docker push ${IMAGE_NAME}:latest
                        docker logout ${REGISTRY}
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
                sh """
                    sleep 10
                    for ip in ${params.EC2_1_IP} ${params.EC2_2_IP}; do
                        echo "Checking http://\$ip:5000/health"
                        curl -fsS --retry 5 --retry-delay 5 http://\$ip:5000/health
                        echo
                    done
                """
            }
        }
    }

    post {
        success { echo 'Deployment successful: both instances healthy.' }
        failure { echo 'Deployment failed. Check the stage logs above.' }
    }
}

// Logs the EC2 host into GHCR (token piped over stdin), pulls the new image and restarts the container.
def deployTo(String host) {
    withCredentials([usernamePassword(credentialsId: 'ghcr-creds',
                                      usernameVariable: 'GHCR_USER',
                                      passwordVariable: 'GHCR_TOKEN')]) {
        sshagent(credentials: ['ec2-ssh-key']) {
            sh """
                echo "\$GHCR_TOKEN" | ssh -o StrictHostKeyChecking=no ${env.SSH_USER}@${host} \
                    "docker login ${env.REGISTRY} -u \$GHCR_USER --password-stdin"

                ssh -o StrictHostKeyChecking=no ${env.SSH_USER}@${host} '
                    docker pull ${env.IMAGE_NAME}:${env.IMAGE_TAG}
                    docker rm -f ${env.CONTAINER_NAME} || true
                    docker run -d --name ${env.CONTAINER_NAME} --restart unless-stopped -p 5000:5000 ${env.IMAGE_NAME}:${env.IMAGE_TAG}
                    docker image prune -f
                '
            """
        }
    }
}
