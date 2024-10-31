pipeline {
    agent any
    environment {
        // Definimos las variables scmUrl y scmBranch globalmente
        SCM_URL = "${env.CHANGE_URL ?: env.GIT_URL}"
        SCM_BRANCH = "${env.CHANGE_BRANCH ?: env.BRANCH_NAME}"
    }
    stages {
        stage('Checkout PR') {
            steps {
                script {
                    if (SCM_URL == null || SCM_BRANCH == null) {
                        error "No se pudo obtener la URL o rama para el checkout. Asegúrate de que el pipeline se ejecute en un contexto de PR."
                    }

                    checkout([$class: 'GitSCM',
                              branches: [[name: SCM_BRANCH]],
                              userRemoteConfigs: [[url: SCM_URL, credentialsId: 'github-credentials-id']]
                    ])
                }
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
                            ${SCM_URL}/pulls/${env.CHANGE_ID}
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
                        ${SCM_URL}/pulls/${env.CHANGE_ID}/reviews
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
