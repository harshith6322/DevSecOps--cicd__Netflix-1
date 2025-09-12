pipeline {
    // agent {
    //     label "slave-1"
    // }

    agent "any"

    tools {
        jdk 'jdk_tool'
        nodejs 'nodejs_tooll'
    }

    environment {
        SCANNER_HOME = tool('sonarqube_scanner_tool')
        build_ide = "$BUILD_ID"
    }

    

    stages {

        stage("Clear ws"){
            steps{
                cleanWs()
            }
        }
        stage("Code checkout") {
            steps {
                git branch: 'main', url: 'https://github.com/harshith6322/DevSecOps-ci-cd-Netflix.git'
            }
        }


        stage("Install Dependencies") {
            steps {
                sh "rm -rf node_modules yarn.lock"
                sh "yarn install"
            }
        }


        stage("Testing"){
           steps{
              sh "yarn test || true"

           }
        }
        

        stage("SonarQube Analysis") {
            steps {
               withSonarQubeEnv("sonarqube_server") {
                   sh """
                      ${SCANNER_HOME}/bin/sonar-scanner \
                       -Dsonar.projectKey=netflix_code \
                       -Dsonar.sources=src \
                       -Dsonar.exclusions=**/node_modules/**,**/dist/**,**/build/**,**/.git/**,**/coverage/**,**/*.min.js \
                       -Dsonar.host.url=http://44.202.0.234:9001 \
                       -Dsonar.login=sqp_98f30737b2edbcbeb0e0182976aa13a25fa97030
                    """  
               }          
            }
        }


        stage("Quality Gate") {
            steps {
                script {
                    timeout(time: 2, unit: 'MINUTES') {
                      waitForQualityGate abortPipeline: false, credentialsId: 'sonar_secert'

                    }          
                }
            }
        }

       
        stage('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./src --disableYarnAudit --disableNodeAudit --exclude **/node_modules/** --exclude **/dist/** --exclude **/build/** --exclude **/.git/**', odcInstallation: 'dp_tool'

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
                       sh "docker build --build-arg TMDB_V3_API_KEY=34b7fa0e189425be905b6072d83b9604 -t harshithreddy6322/netflix_repo:${build_ide} ."
                       sh "docker push harshithreddy6322/netflix_repo:${build_ide}"
                    }
                }
            }
        }

        stage("Docker pull"){
            steps{

                sh "docker pull harshithreddy6322/netflix_repo:${build_ide}"
            }

        }


        stage("TRIVY"){
            steps{
                sh "trivy image harshithreddy6322/netflix_repo:${build_ide} > trivyimage.txt" 
            }
        }
    }
}
