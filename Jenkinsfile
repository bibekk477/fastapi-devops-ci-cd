pipeline {
    agent any

    environment {
        IMAGE_NAME = "bibekk477/fastapi-devops-ci-cd"
        IMAGE_TAG  = "latest"
        REGISTRY   = "docker.io"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "📥 Checking out code from GitHub..."
                checkout scm
            }
        }

        stage('Run Unit Tests') {
            steps {
                echo "🧪 Running unit tests..."
                bat """
                python -m pip install -r requirements.txt
                pytest app/tests --maxfail=1 --disable-warnings -v
                """
            }
        }

        stage('Docker Build') {
            steps {
                echo "🐳 Building Docker image..."
                bat "docker build -t %IMAGE_NAME%:%IMAGE_TAG% ."
                echo "✓ Image built: %IMAGE_NAME%:%IMAGE_TAG%"
            }
        }

        stage('Docker Push to Hub') {
            steps {
                echo "📤 Pushing image to Docker Hub..."
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    bat """
                    docker login -u %DOCKER_USER% -p %DOCKER_PASS%
                    docker push %IMAGE_NAME%:%IMAGE_TAG%
                    docker logout
                    """
                }
                echo "✓ Image pushed to Docker Hub"
            }
        }

        stage('Setup Kubernetes Registry Secret') {
            steps {
                echo "🔐 Creating Docker registry secret in Minikube..."
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                        bat '''
                        set KUBECONFIG=%KUBECONFIG_FILE%
                        
                        REM Create namespace if doesn't exist
                        kubectl create namespace fastapi-ns || echo Namespace already exists
                        
                        REM Delete old secret if exists
                        kubectl delete secret dockerhub-secret -n fastapi-ns || echo No old secret
                        
                        REM Create new registry secret
                        kubectl create secret docker-registry dockerhub-secret ^
                          --docker-server=docker.io ^
                          --docker-username=%DOCKER_USER% ^
                          --docker-password=%DOCKER_PASS% ^
                          --docker-email=bibek@example.com ^
                          -n fastapi-ns
                        
                        echo Secret created successfully
                        '''
                    }
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
        stage('Deploy to Minikube') {
            steps {
                echo "🚀 Deploying to Minikube..."
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                    bat '''
                    REM Set kubeconfig
                    set KUBECONFIG=%KUBECONFIG_FILE%
                    
                    REM Verify kubectl connection
                    kubectl cluster-info
                    
                    REM Apply Kubernetes manifests
                    echo Applying deployment...
                    kubectl apply -f k8s/deployment.yaml -n fastapi-ns
                    
                    echo Applying service...
                    kubectl apply -f k8s/service.yaml -n fastapi-ns
                    
                    REM Wait for deployment to be ready
                    echo Waiting for rollout...
                    kubectl rollout status deployment/fastapi-app -n fastapi-ns --timeout=5m
                    
                    REM Show deployment details
                    echo.
                    echo === DEPLOYMENT STATUS ===
                    kubectl get deployments -n fastapi-ns
                    echo.
                    echo === PODS ===
                    kubectl get pods -n fastapi-ns
                    echo.
                    echo === SERVICES ===
                    kubectl get services -n fastapi-ns
                    echo.
                    echo === SERVICE DETAILS ===
                    kubectl describe service fastapi-service -n fastapi-ns
                    '''
                }
            }
        }

    }

    post {
        success {
            echo "✅ CI/CD Pipeline Completed Successfully!"
            echo "Your app is running on Minikube"
        }
        failure {
            echo "❌ Pipeline Failed - Check logs above"
        }
    }
}
