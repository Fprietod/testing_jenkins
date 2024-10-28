pipeline {
    agent any
    environment {
        ORIGINAL_REPO_URL = 'https://github.com/Fprietod/testing_jenkins.git'
        SONARQUBE_SCANNER_HOME = tool 'SonarQube Scanner' // Nombre configurado del escáner en Global Tool Configuration
    }
    stages {
        stage('Checkout PR') {
            steps {
                // Hacer checkout de la rama del PR del fork
                checkout([$class: 'GitSCM', branches: [[name: env.CHANGE_BRANCH]],
                          userRemoteConfigs: [[url: env.CHANGE_URL, credentialsId: 'tus_credenciales_id']]])
            }
        }
        stage('SonarQube Analysis') {
            steps {
                // Ejecutar el análisis de calidad del código SQL con SonarQube
                withSonarQubeEnv('SonarQube Server') {
                    sh """
                    ${SONARQUBE_SCANNER_HOME}/bin/sonar-scanner \
                    -Dsonar.projectKey=project_key \
                    -Dsonar.sources=. \
                    -Dsonar.host.url=http://ip_publico_sonarqube:9000 \
                    -Dsonar.login=${SONAR_TOKEN}
                    """
                }
            }
        }
        stage('Quality Gate') {
            steps {
                script {
                    timeout(time: 1, unit: 'MINUTES') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "La puerta de calidad no pasó: ${qg.status}"
                        }
                    }
                }
            }
        }
        stage('Approve PR if Quality Check Passes') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                        sh """
                        curl -X POST -H "Authorization: token ${GITHUB_TOKEN}" -H "Accept: application/vnd.github.v3+json" \
                        -d '{"event": "APPROVE"}' \
                        ${env.CHANGE_URL}/pulls/${env.CHANGE_ID}/reviews
                        """
                    }
                }
            }
        }
    }
    post {
        success {
            echo 'Pipeline ejecutado con éxito. El PR ha sido aprobado.'
        }
        failure {
            echo 'El pipeline falló. Revisa los errores de calidad del código SQL.'
        }
    }
}
