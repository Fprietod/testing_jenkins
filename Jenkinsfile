pipeline {
    agent any
    environment {
        SCM_URL = "https://github.com/Fprietod/testing_jenkins.git"
    }
    stages {
        stage('Process PR') {
            steps {
                script {
                    // Define PR_ID y branchToBuild
                    def PR_ID = env.CHANGE_ID
                    def branchToBuild = PR_ID ? "refs/pull/${PR_ID}/head" : "refs/heads/${env.BRANCH_NAME}"
                    
                    // Verifica que esté en el contexto correcto
                    if (!PR_ID && !env.BRANCH_NAME) {
                        error "No se pudo determinar la rama para el checkout. Verifica que el pipeline esté en el contexto correcto."
                    }

                    // Realiza el checkout
                    checkout([$class: 'GitSCM',
                              branches: [[name: branchToBuild]],
                              userRemoteConfigs: [[url: SCM_URL, credentialsId: 'github-credentials-id']],
                              extensions: [[$class: 'CleanBeforeCheckout']]
                    ])
                    
                    // Realiza el análisis con SQLFluff
                    def lintResult = sh(script: 'sqlfluff lint **/*.sql --dialect mysql --rules L001,L002,L003,L004', returnStatus: true)
                    if (lintResult != 0) {
                        if (PR_ID) {  // Si es un PR, intenta cerrarlo
                            withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                                sh """
                                curl -X PATCH -H "Authorization: token ${GITHUB_TOKEN}" -H "Accept: application/vnd.github.v3+json" \
                                -d '{"state": "closed"}' \
                                https://api.github.com/repos/Fprietod/testing_jenkins/pulls/${PR_ID}
                                """
                            }
                        } else {
                            echo "No es un contexto de PR. No se puede cerrar el PR."
                        }
                        error "La validación de calidad no pasó. PR cerrado."
                    } else {
                        // Si la validación pasa, aprueba el PR
                        if (PR_ID) {  // Solo aplica en contexto de PR
                            withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                                sh """
                                curl -X POST -H "Authorization: token ${GITHUB_TOKEN}" -H "Accept: application/vnd.github.v3+json" \
                                -d '{"event": "APPROVE"}' \
                                https://api.github.com/repos/Fprietod/testing_jenkins/pulls/${PR_ID}/reviews
                                """
                            }
                        } else {
                            echo "No es un contexto de PR. No se puede aprobar el PR."
                        }
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
