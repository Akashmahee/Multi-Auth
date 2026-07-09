pipeline {
    agent any

    environment {
        APP_NAME = "multi-auth"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Generate Prisma Client') {
            steps {
                sh 'npx prisma generate'
            }
        }

        stage('Run Prisma Migrations') {
            steps {
                sh 'npx prisma migrate deploy'
            }
        }

        stage('Seed Clients') {
            steps {
                sh 'npm run seed:clients'
            }
        }

        stage('Restart Application') {
            steps {
                sh '''
                pm2 restart multi-auth || pm2 start server.js --name multi-auth
                '''
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                sleep 10
                curl --fail http://localhost:5000 || exit 1
                '''
            }
        }
    }

    post {
        success {
            echo 'Deployment Successful'
        }

        failure {
            echo 'Deployment Failed'
        }
    }
}