pipeline {
    agent any
    environment {
        IMAGE_NAME = "autoheal-app"
        CONTAINER_NAME = "autoheal-app"
        APP_PORT = "3000"
        IMAGE_TAG = "latest"
    }
    stages {
        stage('Clone Repository') {
            steps {
                checkout scm
            }
        }
        stage('Install Dependencies') {
            steps {
                dir('app') {
                    sh 'npm install'
                }
            }
        }
        stage('Run Tests') {
            steps {
                dir('app') {
                    sh 'npm test'
                }
            }
        }
        stage('Prepare Environment') {
            steps {
                sh '''#!/bin/bash
if [ -z "$MONGO_URI" ]; then
  echo "MONGO_URI env var is not set. Configure it in Jenkins (Manage Jenkins -> Configure System -> Global properties)."
  exit 1
fi
cat > .env <<EOF
MONGO_URI=$MONGO_URI
SESSION_SECRET=${SESSION_SECRET:-autoheal_super_secret}
PORT=3000
NODE_ENV=production
EOF
'''
            }
        }
        stage('Tag Previous Stable Image') {
            steps {
                // Tag the currently running image as stable before we build a new one
                sh "docker tag ${IMAGE_NAME}:latest ${IMAGE_NAME}:stable || true"
            }
        }
        stage('Build Docker Image') {
            steps {
                sh "IMAGE_TAG=${IMAGE_TAG} docker-compose -f docker-compose.yml build app"
            }
        }
        stage('Stop Old Container') {
            steps {
                sh "docker stop ${CONTAINER_NAME} || true"
                sh "docker rm ${CONTAINER_NAME} || true"
            }
        }
        stage('Deploy New Container') {
            steps {
                sh "IMAGE_TAG=${IMAGE_TAG} docker-compose -f docker-compose.yml up -d"
            }
        }
        stage('Health Check') {
            steps {
                script {
                    try {
                        sleep 15
                        sh 'curl -f http://localhost:3000/health'
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error("Health check failed")
                    }
                }
            }
        }
        stage('Rollback') {
            when {
                expression { currentBuild.result == 'FAILURE' }
            }
            steps {
                echo "Health check failed. Rolling back to previous stable image..."
                sh "docker stop ${CONTAINER_NAME} || true"
                sh "docker rm ${CONTAINER_NAME} || true"
                sh "docker image inspect ${IMAGE_NAME}:stable >/dev/null 2>&1 && IMAGE_TAG=stable docker-compose -f docker-compose.yml up -d --no-build || echo 'No stable image found for rollback'"
            }
        }
    }
    post {
        success {
            echo "Deployment successful"
        }
        failure {
            echo "Deployment failed. Auto-heal triggered."
        }
    }
}
