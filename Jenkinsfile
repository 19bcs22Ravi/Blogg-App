pipeline {
    agent any
    
    tools {
        maven "maven3"
        jdk 'JDK-21'
    }
    
    environment {
         SCANNER_HOME = tool 'sonar-scanner'
    }

    stages {
        stage('GitCheckOut') {
            steps {
               git branch: 'main', credentialsId: 'git-creds', url: 'https://github.com/19bcs22Ravi/Blogg-App.git'
            }
        }
        
        stage('Compile') {
            steps {
                sh 'mvn compile'
            }
        }
        
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        
        stage('Trivy FS Scan') {
            steps {
                sh 'trivy fs --format table -o fs.html .'
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Blogging-app -Dsonar.projectKey=Blogging \
                          -Dsonar.java.binaries=target/classes'''
                }
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn package'
            }
        }
        
        stage('Publish Artifacts') {
            steps {
                withMaven(globalMavenSettingsConfig: 'maven-settings', maven: 'maven3', traceability: true) {
                    sh 'mvn deploy'
                }
            }
        }
        
        stage('Docker Build Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-creds', toolName: 'docker') {
                        sh 'docker build -t ravi0919/blogg-app:${BUILD_NUMBER} .'
                    }
                }
            }
        }
        
        stage('Trivy ImageScan') {
            steps {
                sh 'trivy image --format table -o image.html ravi0919/blogg-app:${BUILD_NUMBER}'
            }
        }
        
        stage('Docker Push Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-creds', toolName: 'docker') {
                        sh 'docker push ravi0919/blogg-app:${BUILD_NUMBER}'
                    }
                }
            }
        }
        
        stage('Deploy') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'bloggapp-cluster', contextName: '', credentialsId: 'k8-creds', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://2D3BAE0B3DB56FE909157FD249E70BF1.gr7.ap-south-1.eks.amazonaws.com') {
                    sh 'kubectl apply -f deployment-service.yml'
                    sh "kubectl set image deployment/bloggingapp-deployment bloggingapp=ravi0919/blogg-app:${BUILD_NUMBER} -n webapps"
                    sh 'kubectl rollout status deployment/bloggingapp-deployment -n webapps'
                    sleep 30
                }
            }
        }
        
        stage('Check Deployment') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'bloggapp-cluster', contextName: '', credentialsId: 'k8-creds', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://2D3BAE0B3DB56FE909157FD249E70BF1.gr7.ap-south-1.eks.amazonaws.com') {
                    sh 'kubectl get deployments -n webapps'
                    sh 'kubectl get services -n webapps'
                }
            }
        }
    } 
} 