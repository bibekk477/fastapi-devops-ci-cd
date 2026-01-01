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

        stage('Refresh Kubeconfig') {
            steps {
                echo "🔄 Refreshing kubeconfig to match current Minikube state..."
                bat '''
                REM Start Minikube if not running
                minikube status >nul 2>&1
                if errorlevel 1 (
                    echo ⚠️  Minikube not running. Starting...
                    minikube start --driver=docker
                    timeout /t 15
                )
                
                REM Update kubeconfig with latest Minikube configuration
                minikube update-context
                
                REM Verify connection
                kubectl cluster-info
                if errorlevel 1 (
                    echo ❌ Failed to connect to Minikube
                    exit /b 1
                )
                echo ✓ Kubeconfig refreshed
                '''
            }
        }

        stage('Deploy to Minikube') {
            steps {
                echo "🚀 Deploying to Minikube..."
                bat '''
                REM Set kubeconfig to the updated one
                set KUBECONFIG=%USERPROFILE%\.kube\config
                
                REM Verify kubectl connection
                echo Verifying connection...
                kubectl cluster-info || exit /b 1

                REM Ensure namespace exists
                echo Creating namespace...
                kubectl create namespace fastapi-ns || echo Namespace already exists

                REM Apply Kubernetes manifests
                echo Applying deployment...
                kubectl apply -f k8s/deployment.yaml -n fastapi-ns
                
                echo Applying service...
                kubectl apply -f k8s/service.yaml -n fastapi-ns
                
                REM Wait for deployment to be ready
                echo Waiting for rollout...
                kubectl rollout status deployment/fastapi-app -n fastapi-ns --timeout=5m
                if errorlevel 1 (
                    echo ⚠️  Rollout failed. Checking pod status...
                    kubectl describe pods -n fastapi-ns
                    exit /b 1
                )
                
                REM Show deployment details
                echo.
                echo === DEPLOYMENT STATUS ===
                kubectl get deployments -n fastapi-ns
                echo.
                echo === PODS ===
                kubectl get pods -n fastapi-ns -o wide
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
//this stage is not needed since Registry secrets are required only when Kubernetes pulls private images.
//  For public images, Kubernetes can pull directly from Docker Hub without authentication
        // stage('Setup Kubernetes Registry Secret') {
        //     steps {
        //         echo "🔐 Creating Docker registry secret in Minikube..."
        //         withCredentials([usernamePassword(
        //             credentialsId: 'dockerhub-creds',
        //             usernameVariable: 'DOCKER_USER',
        //             passwordVariable: 'DOCKER_PASS'
        //         )]) {
        //             withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
        //                 bat '''
        //                 set KUBECONFIG=%KUBECONFIG_FILE%
                        
        //                 REM Create namespace if doesn't exist
        //                 kubectl create namespace fastapi-ns || echo Namespace already exists
                        
        //                 REM Delete old secret if exists
        //                 kubectl delete secret dockerhub-secret -n fastapi-ns || echo No old secret
                        
        //                 REM Create new registry secret
        //                 kubectl create secret docker-registry dockerhub-secret ^
        //                   --docker-server=docker.io ^
        //                   --docker-username=%DOCKER_USER% ^
        //                   --docker-password=%DOCKER_PASS% ^
        //                   --docker-email=bibek@example.com ^
        //                   -n fastapi-ns
                        
        //                 echo Secret created successfully
        //                 '''
        //             }
        //         }
        //     }
        // }


// Minikube start stage is commented out because it often fails in Windows CI environments.
//ensure minikube is already running before deploying.
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
//         stage('Deploy to Minikube') {
//             steps {
//                 echo "🚀 Deploying to Minikube..."
//                 withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
//                     bat '''
//                     REM Set kubeconfig
//                     set KUBECONFIG=%KUBECONFIG_FILE%
                    
//                     REM Verify kubectl connection
//                     kubectl cluster-info || exit /b 1

//                     REM Verify namespaces exist
//                     echo Ensuring namespace exists...
//                     kubectl create namespace fastapi-ns || echo Namespace already exists

                    
//                     REM Apply Kubernetes manifests
//                     echo Applying deployment...
//                     kubectl apply -f k8s/deployment.yaml -n fastapi-ns
                    
//                     echo Applying service...
//                     kubectl apply -f k8s/service.yaml -n fastapi-ns
                    
//                     REM Wait for deployment to be ready
//                     echo Waiting for rollout...
//                     kubectl rollout status deployment/fastapi-app -n fastapi-ns --timeout=5m
                    
//                     REM Show deployment details
//                     echo.
//                     echo === DEPLOYMENT STATUS ===
//                     kubectl get deployments -n fastapi-ns
//                     echo.
//                     echo === PODS ===
//                     kubectl get pods -n fastapi-ns
//                     echo.
//                     echo === SERVICES ===
//                     kubectl get services -n fastapi-ns
//                     echo.
//                     echo === SERVICE DETAILS ===
//                     kubectl describe service fastapi-service -n fastapi-ns
//                     '''
//                 }
//             }
//         }

//     }

//     post {
//         success {
//             echo "✅ CI/CD Pipeline Completed Successfully!"
//             echo "Your app is running on Minikube"
//         }
//         failure {
//             echo "❌ Pipeline Failed - Check logs above"
//         }
//     }
// }
