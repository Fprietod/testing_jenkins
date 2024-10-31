pipeline {
    agent any
    environment {
        SCM_URL = "https://github.com/Fprietod/testing_jenkins.git"
    }
    stages {
        stage('Initialize') {
            steps {
                script {
                    // Asigna el valor de env.CHANGE_ID a la variable global PR_ID
                    PR_ID = env.CHANGE_ID
                    echo "PR_ID inicializado: ${PR_ID}"
                }
            }
        }
        stage('Checkout PR') {
            steps {
                script {
                    // Usa PR_ID para definir branchToBuild
                    def branchToBuild = PR_ID ? "refs/pull/${PR_ID}/head" : "refs/heads/${env.BRANCH_NAME}"
                    
                    if (!PR_ID && !env.BRANCH_NAME) {
                        error "No se pudo determinar la rama para el checkout. Verifica que el pipeline esté en el contexto correcto."
                    }

                    checkout([$class: 'GitSCM',
                              branches: [[name: branchToBuild]],
                              userRemoteConfigs: [[url: SCM_URL, credentialsId: 'github-credentials-id']],
                              extensions: [[$class: 'CleanBeforeCheckout']]
                    ])
                }
            }
        }
        stage('SQLFluff Analysis') {
            steps {
                script {
                    def lintResult = sh(script: 'sqlfluff lint **/*.sql --dialect mysql --rules L001,L002,L003,L004', returnStatus: true)
                    if (lintResult != 0) {
                        if (PR_ID) {  // Usa PR_ID en lugar de env.CHANGE_ID
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
                    }
                }
            }
        }
        stage('Approve PR if Quality Check Passes') {
            steps {
                script {
                    if (PR_ID) {  // Usa PR_ID en lugar de env.CHANGE_ID
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
    post {
        success {
            echo 'Pipeline ejecutado con éxito. PR aprobado.'
        }
        failure {
            echo 'El pipeline falló. Revisa los errores de calidad del código SQL.'
        }
    }
}
