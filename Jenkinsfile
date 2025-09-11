pipeline {
    agent {
        label "slave-1"
    }

    tools {
        jdk 'jdk_tool'
        nodejs 'nodejs_tool'
    }

    environment {
        SCANNER_HOME = tool('sonarqube_scanner_tool')
    }

    stages {
        stage("Code") {
            steps {
                git branch: 'main', url: 'https://github.com/harshith6322/DevSecOps-ci-cd-Netflix.git'
            }
        }

        stage("SonarQube Analysis") {
            steps {
               
                   sh """
${SCANNER_HOME}/bin/sonar-scanner \
  -Dsonar.projectKey=netflix_code \
  -Dsonar.sources=src \
  -Dsonar.exclusions=**/node_modules/**,**/dist/**,**/build/**,**/.git/**,**/coverage/**,**/*.min.js \
  -Dsonar.host.url=http://54.204.255.166:9000 \
  -Dsonar.login=sqp_d1cf341d438b4e4dbf70f0a6547cf9258eedea6b
"""
              
            }
        }

        stage("Quality Gate") {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token'
                }
            }
        }

        stage("Install Dependencies") {
            steps {
                sh "npm install"
            }
        }
    }
}
