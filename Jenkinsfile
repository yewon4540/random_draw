pipeline {
  agent any

  environment {
    FLASK_SERVER = "ubuntu@172.31.41.38"
    PROJECT_DIR = "/home/ubuntu/random_draw"
  }

  stages {
    stage('Deploy to Flask Server') {
      steps {
        script {
          // 실패해도 파이프라인은 계속 진행되게 하고
          // 성공 여부를 변수로 판단
          try {
            sshagent (credentials: ['credential_key']) {
              sh """
                ssh -o StrictHostKeyChecking=no $FLASK_SERVER '
                  cd $PROJECT_DIR &&
                  git pull origin main &&
                  sh deploy.sh
                '
              """
            }
            env.DEPLOY_RESULT = 'SUCCESS'
          } catch (e) {
            env.DEPLOY_RESULT = 'FAILURE'
            currentBuild.result = 'FAILURE'  // 실제 빌드 결과에도 반영
          }
        }
      }
    }

    stage('Notify to Mattermost') {
      steps {
        withCredentials([string(credentialsId: 'mattermost_webhook_url', variable: 'MM_WEBHOOK')]) {
          script {
            def msg = ''
            def icon = ''
            if (env.DEPLOY_RESULT == 'SUCCESS') {
              msg = ":white_check_mark: Jenkins 빌드 **성공**! 배포 완료 🎉"
              icon = "https://www.jenkins.io/images/logos/jenkins/jenkins.png"
            } else {
              msg = ":x: Jenkins 빌드 **실패**... 확인이 필요합니다. ❗"
              icon = "https://www.jenkins.io/images/logos/jenkins/jenkins.png"
            }

            sh """
              curl -X POST -H "Content-Type: application/json" \\
              -d '{
                "text": "${msg}",
                "username": "jenkins-bot",
                "icon_url": "${icon}"
              }' \\
              \$MM_WEBHOOK
            """
          }
        }
      }
    }
  }
}

