pipeline{


    agent{
        label "slave-1"
    }
  
   tools{
      jdk 'jdk_tool'
      nodejs 'nodejs_tool'
    }
    


    environment{
      SCANNER_HOME=tool 'sonarqube_scanner'
    }


    stages{

      stage("Code"){
        steps{
           git branch: 'main', url: 'https://github.com/harshith6322/DevSecOps-ci-cd-Netflix.git'
        }
      }

      stage("Sonarqube Analysis"){
        steps{


            withSonarQubeEnv(credentialsId: 'sonar_qube_server') {

                  sh '''sonarqube_scanner \
            -Dsonar.projectKey=jenkins-netflix-code \
            -Dsonar.sources=. \
            -Dsonar.host.url=http://18.234.112.226:9000 \
            -Dsonar.login=sqp_71d6e076c5333d82405859bac907bf2c81830007'''
        }
    // some block
}
          

      }

       stage("Quality gate"){
           steps{
                script{
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar_qube_server' 
                }
            } 
        }


        stage('Intall dep'){

            steps{
              
              sh "npm install "

            }
        }


    }



  

}