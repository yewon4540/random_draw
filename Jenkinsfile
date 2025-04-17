pipeline {
  agent any

  environment {
    FLASK_SERVER = "USER@HOST"
    PROJECT_DIR = "PATH"
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

