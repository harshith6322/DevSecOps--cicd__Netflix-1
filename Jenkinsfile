pipeline {

    tools{
        jdk "jdk-17"
        nodejs "nodejs-24"
    }

    // agent{
        // label 'my-label1 && my-label2' // Agent must have both 'my-label1' AND 'my-label2'
    //     lable 'nodejs'
    //     retries 3
        
    // }

    // agent {
    //     label {
    //       label 'nodejs'
    //       retries 3
    //     }
    // }

    agent "any"

    environment{
        scannerHome = tool("sonarqube-tool")

        build_id = "$BUILD_ID"

        RECIPIENTS = "noreply.jenkins2025@gmail.com,rrchennareddy1971@gmail.com"
    }



    stages{
        stage("CLEAN WORKSPACE"){
            steps{
                cleanWs()
            }
        }

        stage("CODE"){
            steps{
                git branch: 'main', url: 'https://github.com/harshith6322/DevSecOps--cicd__Netflix-1.git'
            }
        }

        stage("CQA-SONAR"){
            steps{
                withSonarQubeEnv("sonarqube-server") {
                    sh '''
                       ${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=NETFLIX-APP \
                        -Dsonar.sources=src \
                        -Dsonar.exclusions=**/node_modules/**,**/dist/**,**/build/**,**/.git/**,**/coverage/**,**/*.min.js
                    '''

                }
            }
        }

        stage("QULITY-GATE"){
            steps{
                waitForQualityGate abortPipeline: false, credentialsId: 'sonar-server-cred'
            }
        }


        stage("BUILD"){
            steps{
                sh "yarn install"
            }
        }

        stage("OWASP"){
            steps{
                dependencyCheck additionalArguments: '''--project Netflix --scan ./src --format XML --disableYarnAudit --disableNodeAudit''', debug: true, nvdCredentialsId: 'owasp-cred', odcInstallation: 'dpc-tool'      
            }
        }


        stage("FS AND TEST"){
            parallel{

              stage("TRIVY FS"){
                steps{
                    sh "trivy fs . > trivy-fs-report.log"
                }
              }

              stage("TEST"){
                steps {
                    sh "yarn test || true"
                }

              }

            }
        }


        stage("DOCKER BUILD"){
            steps{

               script{
                 withDockerRegistry(credentialsId: 'docker-cred') {
                 // some block
                 sh "docker build -t harshithreddy6322/netflix_repo:${build_id} --build-arg TMDB_V3_API_KEY=34b7fa0e189425be905b6072d83b9604 ."
                 sh "docker push harshithreddy6322/netflix_repo:${build_id}"

                }
               }

            }
        }


        stage("TRIVY IMAGE SCAN"){
            steps{
                sh "trivy image harshithreddy6322/netflix_repo:${build_id} > trivyimage_logs.log" 
            }
        }


        stage("CHECKIG DOCKER"){
            steps{
                sh "docker pull harshithreddy6322/netflix_repo:${build_id}"
                sh "docker run -itd harshithreddy6322/netflix_repo:${build_id}"
                sh "sleep 2m"
                sh "docker rm -f harshithreddy6322/netflix_repo:${build_id}"
            }
        }

        
    }

    post {
    always {
        script {
            def emoji = ''
            switch (currentBuild.result) {
                case 'SUCCESS':
                    emoji = '✔️'
                    break
                case 'FAILURE':
                    emoji = '❌'
                    break
                case 'UNSTABLE':
                    emoji = '⚠️'
                    break
                default:
                    emoji = '❔'
            }

            emailext(
                subject: "${emoji} ${JOB_NAME} #${BUILD_NUMBER} - ${currentBuild.result}",
                body: getEmailBody(),
                mimeType: 'text/html',
                to: "${RECIPIENTS}",
                attachLog: true,
                compressLog: true,
                attachmentsPattern: 'trivyimage_logs.log,dependency-check-report.xml,trivy-fs-report.log'
            )
        }
    }
}


 
}


// Function to load HTML email body
@NonCPS
def getEmailBody() {
    return """
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; background:#f6f9fc; padding:20px; }
        .container { max-width:600px; margin:auto; background:#fff; border-radius:8px;
                     box-shadow:0 2px 8px rgba(0,0,0,0.1); padding:20px; }
        h2 { text-align:center; }
        .status-success { color: #2e7d32; font-weight: bold; }
        .status-failed { color: #c62828; font-weight: bold; }
        .button { display:inline-block; padding:10px 20px; margin-top:10px; 
                  font-size:14px; font-weight:bold; text-decoration:none;
                  border-radius:4px; color:#fff; }
        .btn-success { background:#2e7d32; }
        .btn-failed { background:#c62828; }
        .footer { text-align:center; font-size:12px; color:#777; margin-top:20px; }
      </style>
    </head>
    <body>
      <div class="container">
        <h2>CI/CD Pipeline Report</h2>
        <p><strong>Project:</strong> ${env.JOB_NAME}</p>
        <p><strong>Branch:</strong> ${env.BRANCH_NAME ?: 'N/A'}</p>
        <p><strong>Build Number:</strong> #${env.BUILD_NUMBER}</p>
        <p><strong>Status:</strong> <span class="${currentBuild.result== 'SUCCESS' ? 'status-success' : 'status-failed'}">${currentBuild.result}</span></p>
        <a class="button ${currentBuild.result == 'SUCCESS' ? 'btn-success' : 'btn-failed'}" href="${env.BUILD_URL}">View Build Logs</a>
        <div class="footer">
          <p>This is an automated message from Jenkins CI/CD</p>
          
        </div>
      </div>
    </body>
    </html>
    """
} 