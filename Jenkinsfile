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
                waitForQualityGate abortPipeline: false, credentialsId: 'sonar-secret'
            }
        }


        stage("BUILD"){
            steps{
                sh "yarn install"
            }
        }

        // stage("OWASP"){
        //     steps{
        //         dependencyCheck additionalArguments: '''
        //         --project netflix \
        //         --scan ./ \
        //         --format "XML,HTML" \
        //         --out dependency-check-report \
        //         --disableYarnAudit \
        //         --disableNodeAudit \
        //         --exclude **/node_modules/** \
        //         --exclude **/dist/** \
        //         --exclude **/build/** \
        //         --exclude **/.git/**
        //         ''',
        //         odcInstallation: 'dp_tool'
        //         dependencyCheckPublisher pattern: 'dependency-check-report/dependency-check-report.xml'
               
        //     }
        // }


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
                 sh "docker build -t harshithreddy6322/netflix_repo:${BUILD_ID} --build-arg TMDB_V3_API_KEY=34b7fa0e189425be905b6072d83b9604 ."
                 sh "docker push harshithreddy6322/netflix_repo:${BUILD_ID}"

                }
               }

            }
        }


        stage("CHECKIG DOCKER"){
            steps{
                sh "docker pull harshithreddy6322/netflix_repo:${BUILD_ID}"
                sh "docker run -itd harshithreddy6322/netflix_repo:${BUILD_ID}"
            }
        }


        stage("TRIVY IMAGE SCAN"){
            steps{
                sh "trivy image harshithreddy6322/netflix_repo:${BUILD_ID} > trivyimage.txt" 
            }
        }




        
    }
}