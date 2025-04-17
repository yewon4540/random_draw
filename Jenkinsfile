pipeline {
  agent any

  environment {
    FLASK_SERVER = "ubuntu@172.31.41.38"
    PROJECT_DIR = "/home/ubuntu/random_draw"
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

  post {
    success {
      withCredentials([string(credentialsId: 'mattermost_webhook_url', variable: 'MM_WEBHOOK')]) {
        sh """
        curl -X POST -H 'Content-Type: application/json' \\
          -d '{
            "text": ":white_check_mark: Jenkins 빌드 **성공**! 배포 완료 🎉",
            "username": "jenkins-bot",
            "icon_url": "https://www.jenkins.io/images/logos/jenkins/jenkins.png"
          }' \\
          \$MM_WEBHOOK
        """
      }
    }

    failure {
      withCredentials([string(credentialsId: 'mattermost_webhook_url', variable: 'MM_WEBHOOK')]) {
        sh """
        curl -X POST -H 'Content-Type: application/json' \\
          -d '{
            "text": ":x: Jenkins 빌드 **실패**... 확인이 필요합니다. ❗",
            "username": "jenkins-bot",
            "icon_url": "https://www.jenkins.io/images/logos/jenkins/jenkins.png"
          }' \\
          \$MM_WEBHOOK
        """
      }
    }

    always {
      echo "📝 빌드 종료 - 성공 여부와 관계없이 실행됨"
    }
  }
}

