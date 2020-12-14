timestamps {
    node {

        properties([
            [$class: 'jenkins.model.BuildDiscarderProperty', strategy: [$class: 'LogRotator',
                artifactDaysToKeepStr: '5',
                artifactNumToKeepStr: '5',
                daysToKeepStr: '15',
                numToKeepStr: '5']
            ]]);

        stage('Prepare') {
             checkout scm
        }

        final def jdks = ['OpenJDK11','OpenJDK8']

        jdks.eachWithIndex { jdk, indexOfJdk ->
            final String jdkTestName = jdk.toString()
            withEnv(["JAVA_HOME=${ tool jdkTestName }", "PATH+MAVEN=${tool 'Maven CURRENT'}/bin:${env.JAVA_HOME}/bin"]) {
                stage("Build ${jdkTestName}") {
                    echo "Building branch: ${env.BRANCH_NAME}"
                    sh "mvn install -Dmaven.test.skip=true -B -V -fae -q -pl '!dist'"
                }

                stage("Test ${jdkTestName}") {
                    echo "Running unit tests"
                    sh "mvn -e test verify -B -pl '!dist'"
                }
            }
        }

        stage('Publish Test Results'){
            junit allowEmptyResults: true, testResults: '**/target/surefire-reports/TEST-*.xml, **/target/failsafe-reports/TEST-*.xml'
            jacoco classPattern: '**/target/classes', execPattern: '**/target/**.exec'
        }

        withEnv(["JAVA_HOME=${ tool 'OpenJDK8' }", "PATH+MAVEN=${tool 'Maven CURRENT'}/bin:${env.JAVA_HOME}/bin"]) {
            stage('Check Javadocs') {
                sh "mvn javadoc:javadoc"
            }

            stage('Check Test Javadocs') {
                sh "mvn javadoc:test-javadoc"
            }

            stage('OWASP Dependency Check') {
                echo "Uitvoeren OWASP dependency check"
                sh "mvn org.owasp:dependency-check-maven:aggregate"
                dependencyCheckPublisher failedNewCritical: 1, unstableNewHigh: 1, unstableNewLow: 1, unstableNewMedium: 1
            }
        }
    }
}
