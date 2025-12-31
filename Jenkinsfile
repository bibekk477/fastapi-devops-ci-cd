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

        // Minikube needs user-level Docker access, not SYSTEM.Result: API server container never starts.
        // Minikube is designed for local interactive use, not Windows CI pipelines.

stage('Deploy via Ansible') {
    steps {
        bat """
        docker run --rm ^
          -v %WORKSPACE%:/work ^
          -w /work ^
          python:3.12-slim bash -c ^
          "apt-get update && apt-get install -y curl && \
           curl -LO https://dl.k8s.io/release/\\$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl && \
           install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
           pip install --quiet --disable-pip-version-check ansible && \
           ansible-playbook -i ansible/inventory.ini ansible/deploy.yml --connection=local"
        """
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
       