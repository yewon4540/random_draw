pipeline {
  agent any

  environment {
    FLASK_SERVER = "ubuntu@172.31.41.38"
    PROJECT_DIR = "/home/ubuntu/random_draw"
  }

  triggers {
    githubPush()
  }

  stages {
    stage('Deploy to Flask Server') {
      steps {
        sshagent (credentials: ['credential_key']) {
          sh """
            ssh -o StrictHostKeyChecking=no $FLASK_SERVER '
              cd $PROJECT_DIR &&
              git pull origin main &&
              sh deploy.sh
            '
          """
        }
      }
    }
  }
}

