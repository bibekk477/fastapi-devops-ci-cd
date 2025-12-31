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

stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                    bat '''
                    REM Copy kubeconfig to a temp location
                    copy "%KUBECONFIG_FILE%" "%TEMP%\\kubeconfig"
                    
                    REM Set kubeconfig environment variable
                    set KUBECONFIG=%TEMP%\\kubeconfig
                    
                    REM Create namespace if it doesn't exist
                    kubectl create namespace fastapi-app || true
                    
                    REM Apply Kubernetes manifests
                    kubectl apply -f k8s/deployment.yaml -n fastapi-app
                    kubectl apply -f k8s/service.yaml -n fastapi-app
                    
                    REM Wait for rollout to complete
                    kubectl rollout status deployment/fastapi-app -n fastapi-app --timeout=5m
                    
                    REM Show deployment status
                    kubectl get deployments -n fastapi-app
                    kubectl get services -n fastapi-app
                    kubectl get pods -n fastapi-app
                    
                    REM Cleanup
                    del "%TEMP%\\kubeconfig"
                    '''
                }
            }
        }

    }
    post {
        success {
            echo " CI/CD pipeline completed successfully"
        }
        failure {
            echo " Pipeline failed — deployment blocked"
        }
    }
}
       