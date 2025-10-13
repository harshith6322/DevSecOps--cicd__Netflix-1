Pipelines{

    tools{
        jdk "jdk-17"
        nodejs "nodejs-17"
    }

    agent{
        lable 'aws,netflix,dynamic,nodejs'
          retries 3
        
    }

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
                   sh """ 
                        ${scannerHome}/bin/sonar-scanner \
                        sonar.projectKey=NETFLIX-APP \
                        -Dsonar.sources=src \
                        -Dsonar.exclusions=**/node_modules/**,**/dist/**,**/build/**,**/.git/**,**/coverage/**,**/*.min.js \
                        
                      """


                }
            }
        }

        stage("QULITY-GATE"){
            waitForQualityGate abortPipeline: false, credentialsId: 'sonar-secret'
        }
    }
}