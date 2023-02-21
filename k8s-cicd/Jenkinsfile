pipeline {
    agent any
    options {
        timeout(time: 3, unit: 'HOURS')
    }  
    environment {
        registry = "prempalsingh/k8scicd"
        GOCACHE = "/tmp"
    }
    stages {
        stage('Build') {
            agent { 
                any { 
                    image 'golang' 
                }
            }
            steps {
                // Create our project directory.
                //sh 'cd src'
                sh 'mkdir -p src/hello-world'
                // Copy all files in our Jenkins workspace to our project directory.                
                sh 'cp -r ${WORKSPACE}/* src/hello-world'
                // started Stage Build
                echo "Started Stage Build"
                sleep(time: 5, unit: "SECONDS")
                // Build the app.
                sh 'go build'               
            }     
        }
        stage('Test') {
            agent { 
                any { 
                    image 'golang' 
                }
            }
            steps {                 
                // Create our project directory.
                //sh 'cd src'
                sh 'mkdir -p src/hello-world'
                // Copy all files in our Jenkins workspace to our project directory.                
                sh 'cp -r ${WORKSPACE}/* src/hello-world'
                // started Stage Test
                echo "Started Stage Test"
                sleep(time: 5, unit: "SECONDS")
                // Remove cached test results.
                sh 'go clean -cache'
                // Run Unit Tests.
                sh 'go test ./... -v -short'            
            }
        }
        stage('Publish') {
            environment {
                registryCredential = 'access-token'
            }
            steps{
                script {
                    def appimage = docker.build registry + ":$BUILD_NUMBER"
                    docker.withRegistry( '', registryCredential ) {
                        appimage.push()
                        appimage.push('latest')
                    }
                }
            }
        }
        stage ('Deploy') {
            steps {
                script{
                    def image_id = registry + ":$BUILD_NUMBER"
                    sh "ansible-playbook  playbook.yml --extra-vars \"image_id=${image_id}\""
                }
            }
        }
    }
}
