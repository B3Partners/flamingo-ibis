timestamps {
    node {

        properties([
            [$class: 'jenkins.model.BuildDiscarderProperty', strategy: [$class: 'LogRotator',
                artifactDaysToKeepStr: '8',
                artifactNumToKeepStr: '3',
                daysToKeepStr: '15',
                numToKeepStr: '5']
            ]]);

        withEnv(["JAVA_HOME=${ tool 'JDK8' }", "PATH+MAVEN=${tool 'Maven 3.5.2'}/bin:${env.JAVA_HOME}/bin"]) {

            stage('Prepare') {
                 checkout scm
            }

            stage('Build') {
                echo "Building branch: ${env.BRANCH_NAME}"
                sh "mvn install -Dmaven.test.skip=true -B -V -fae -q -pl '!dist'"
            }

            stage('Test') {
                echo "Running unit tests"
                sh "mvn -e test verify -B -pl '!dist'"
            }

            stage('Publish Results'){
                junit allowEmptyResults: true, testResults: '**/target/surefire-reports/TEST-*.xml, **/target/failsafe-reports/TEST-*.xml'
            }

            stage('OWASP Dependency Check') {
                sh "mvn org.owasp:dependency-check-maven:aggregate -Dformat=XML -DsuppressionFile=./.mvn/owasp-suppression.xml"

                dependencyCheckPublisher canComputeNew: false, defaultEncoding: '', healthy: '85', pattern: '**/dependency-check-report.xml', shouldDetectModules: true, unHealthy: ''
            }
        }
    }
}
