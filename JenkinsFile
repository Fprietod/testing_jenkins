pipeline {
    agent any
    environment {
        ORIGINAL_REPO_URL = 'https://github.com/Fprietod/testing_jenkins.git'
    }
    stages {
        stage('Checkout PR') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: env.CHANGE_BRANCH]],
                          userRemoteConfigs: [[url: env.CHANGE_URL, credentialsId: 'github-credentials-id']]])
            }
        }
        stage('SQLFluff Analysis') {
            steps {
                script {
                    // Run SQLFluff linting on SQL files
                    def lintResult = sh(script: 'sqlfluff lint **/*.sql --dialect your_sql_dialect --rules L001,L002,L003,L004', returnStatus: true)
                    if (lintResult != 0) {
                        // Close PR if SQL quality check fails
                        withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                            sh """
                            curl -X PATCH -H "Authorization: token ${GITHUB_TOKEN}" -H "Accept: application/vnd.github.v3+json" \
                            -d '{"state": "closed"}' \
                            ${env.CHANGE_URL}/pulls/${env.CHANGE_ID}
                            """
                        }
                        error "SQL quality check failed. PR closed."
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
            echo 'Pipeline executed successfully. PR approved.'
        }
        failure {
            echo 'Pipeline failed. Check SQL quality errors.'
        }
    }
}
