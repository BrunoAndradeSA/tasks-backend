pipeline {
  agent any
  stages {
    stage ('Build Backend') {
      steps {
        sh 'mvn clean package -DskipTests=true'
      }
    }
    stage ('Unit Tests') {
      steps {
        sh 'mvn test'
      }
    }
    stage ('Sonar Analysis') {
      environment {
        scannerHome = tool 'SonarQubeScanner'
      }
      steps {
        withSonarQubeEnv('SonarQube') {
          sh "${scannerHome}/bin/sonar-scanner -e -Dsonar.projectKey=TasksBackend -Dsonar.host.url=http://localhost:9000/sonarqube -Dsonar.login=7b544c3c929951a36ef8a624b10e8bfbdd578f2f -Dsonar.java.binaries=target -Dsonar.coverage.exclusions=**/.mvn/**,**/src/test/**,**/model/**,**Application.java"
        }
      }
    }
    stage ('Quality Gate') {
      steps {
        sleep(5)
        timeout(time: 1, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }
    stage ('Deploy Backend') {
      steps {
        deploy adapters: [tomcat9(credentialsId: 'TomcatLocal', path: '', url: 'http://localhost:8088/')], contextPath: 'tasks-backend', war: 'target/tasks-backend.war'
      }
    }
    stage ('API Test') {
      steps {
        dir ('api-test') {
          git credentialsId: 'GitHub', url: 'https://github.com/BrunoAndradeSA/tasks-api-test.git'
          sh 'mvn test'
        }
      }
    }
    stage ('Deploy Frontend') {
      steps {
        dir ('frontend') {
          git credentialsId: 'GitHub', url: 'https://github.com/BrunoAndradeSA/tasks-frontend.git'
          sh 'mvn clean package'
          deploy adapters: [tomcat9(credentialsId: 'TomcatLocal', path: '', url: 'http://localhost:8088/')], contextPath: 'tasks', war: 'target/tasks.war'
        }
      }
    }
    stage ('Functional Test') {
      steps {
        dir ('functional-test') {
          git credentialsId: 'GitHub', url: 'https://github.com/BrunoAndradeSA/tasks-functional-tests.git'
          sh 'mvn test'
        }
      }
    }
    stage ('Deploy Prod') {
      steps {
        sh 'docker-compose build'
        sh 'docker-compose up -d'
      }
    }
    stage ('Health Check') {
      steps {
        sleep(5)
        dir ('functional-test') {
          sh 'mvn verify -Dskip.surefire.tests'
        }
      }
    }
  }
  post {
    always {
      junit allowEmptyResults: true, testResults: 'target/surefire-reports/*.xml, api-test/target/surefire-reports/*.xml, functional-test/target/surefire-reports/*.xml, target/failsafe-reports/*.xml'
    }
  }
}