pipeline {
    agent any
    environment {
        IMAGE_NAME = "autoheal-app"
        CONTAINER_NAME = "autoheal-app"
        APP_PORT = "3000"
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
        stage('Tag Previous Stable Image') {
            steps {
                // Tag the currently running image as stable before we build a new one
                sh "docker tag ${IMAGE_NAME}:latest ${IMAGE_NAME}:stable || true"
            }
        }
        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:latest ./app"
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
                // Ensure .env exists in Jenkins workspace
                sh "touch .env" 
                sh "docker run -d --name ${CONTAINER_NAME} --restart unless-stopped -p ${APP_PORT}:3000 --env-file .env ${IMAGE_NAME}:latest"
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
                sh "docker run -d --name ${CONTAINER_NAME} --restart unless-stopped -p ${APP_PORT}:3000 --env-file .env ${IMAGE_NAME}:stable || true"
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
