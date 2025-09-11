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
        build_ide = "$BUILD_ID"
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

        // stage("Quality Gate") {
        //     steps {
        //         script {
                    
        //             waitForQualityGate abortPipeline: false, credentialsId: 'sonar_secert'
        //         }
        //     }
        // }

        stage("Install Dependencies") {
            steps {
                sh "npm install"
            }
        }

         stage('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }
        stage("Docker Build & Push"){
            steps{
                script{
                   withDockerRegistry(credentialsId: 'docker_token'){   
                       sh "docker build --build-arg TMDB_V3_API_KEY=34b7fa0e189425be905b6072d83b9604 -t netflix_repo:${build_ide} ."
                       sh "docker push harshithreddy6322/netflix_repo:${build_ide}"
                    }
                }
            }
        }

        stage("TRIVY"){
            steps{
                sh "trivy image harshithreddy6322/netflix:${build_ide} > trivyimage.txt" 
            }
        }
    }
}
