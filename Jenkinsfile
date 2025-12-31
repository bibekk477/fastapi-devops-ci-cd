pipeline {
    agent any

    environment {
        IMAGE_NAME = "bibekk477/fastapi-devops-ci-cd"
        IMAGE_TAG  = "latest"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Run Unit Tests (Local)') {
            steps {
                bat """
                python -m pip install -r requirements.txt
                pytest app/tests --maxfail=1 --disable-warnings -q
                """
            }
        }

        stage('Docker Build & Test') {
            steps {
                bat "docker build -t %IMAGE_NAME%:%IMAGE_TAG% ."
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    bat """
                    docker login -u %DOCKER_USER% -p %DOCKER_PASS%
                    docker push %IMAGE_NAME%:%IMAGE_TAG%
                    """
                }
            }
        }

        // stage('Start Minikube') {
        //     steps {
        //         bat """
        //         minikube start --driver=docker
        //         minikube status
        //         """
        //     }
        // }

        stage('Deploy via Ansible') {
            steps {
                bat "wsl ansible-playbook ansible/deploy.yml"
            }
        }

    }

    post {
        success {
            echo "✅ CI/CD pipeline completed successfully"
        }
        failure {
            echo "❌ Pipeline failed — deployment blocked"
        }
    }
}
