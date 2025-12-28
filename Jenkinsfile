pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install dependencies') {
            steps {
                echo "installing dependencies using pip"
                bat 'python -m pip install --upgrade pip'
                bat 'pip install -r requirements.txt'
            }
        }

        stage('Run Tests') {
            steps {
                bat 'pytest app/tests --maxfail=1 --disable-warnings -q'
            }
        }
    }

    post {
        success {
            echo '✅ Tests passed!'
        }
        failure {
            echo '❌ Tests failed'
        }
    }
}
