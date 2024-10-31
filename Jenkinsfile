pipeline {
    agent any
    environment {
        CHANGE_URL = env.CHANGE_URL  // URL dinámica del fork
        CHANGE_BRANCH = env.CHANGE_BRANCH  // Rama dinámica del fork
    }
    stages {
        stage('Checkout PR') {
            steps {
                checkout([$class: 'GitSCM',
                          branches: [[name: env.CHANGE_BRANCH]],
                          userRemoteConfigs: [[url: env.CHANGE_URL, credentialsId: 'github-credentials-id']]
                ])
            }
        }
        stage('SQLFluff Analysis') {
            steps {
                script {
                    def lintResult = sh(script: 'sqlfluff lint **/*.sql --dialect tu_dialecto_sql --rules L001,L002,L003,L004', returnStatus: true)
                    if (lintResult != 0) {
                        withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                            sh """
                            curl -X PATCH -H "Authorization: token ${GITHUB_TOKEN}" -H "Accept: application/vnd.github.v3+json" \
                            -d '{"state": "closed"}' \
                            ${env.CHANGE_URL}/pulls/${env.CHANGE_ID}
                            """
                        }
                        error "La validación de calidad no pasó. PR cerrado."
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
            echo 'Pipeline ejecutado con éxito. PR aprobado.'
        }
        failure {
            echo 'El pipeline falló. Revisa los errores de calidad del código SQL.'
        }
    }
}
