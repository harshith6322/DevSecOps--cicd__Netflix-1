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
               script{
                dependencyCheck additionalArguments: '''--project Netflix --scan ./src --format XML''', debug: true, nvdCredentialsId: 'owasp-cred', odcInstallation: 'dpc-tool'
                dependencyCheckPublisher pattern: 'dependencyCheckPublisher_report.xml'
               }
            }
        }


        stage("FS AND TEST"){
            parallel{

              stage("TRIVY FS"){
                steps{
                    sh "trivy fs . >> trivy-fs-report.txt"
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


        stage("CHECKIG DOCKER"){
            steps{
                sh "docker pull harshithreddy6322/netflix_repo:${build_id}"
                sh "docker run -itd harshithreddy6322/netflix_repo:${build_id}"
            }
        }


        stage("TRIVY IMAGE SCAN"){
            steps{
                sh "trivy image harshithreddy6322/netflix_repo:${build_id} > trivyimage.txt" 
            }
        }




        
    }
}