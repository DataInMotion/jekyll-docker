pipeline {
	environment {
		NAME = "jekyll"
		VERSION = "${env.BUILD_ID}"
		IMAGE = "${NAME}:${VERSION}"
	}
	
	agent any
    	stages {
		stage('Jekyll Build') {
		    steps {
			step([$class: 'DockerBuilderPublisher',
				dockerFileDirectory: '.',
				cloud: 'docker',
				tagsString: """devel.data-in-motion.biz:6000/infrastructure/${NAME}:latest
					devel.data-in-motion.biz:6000/infrastructure/${NAME}:${VERSION}""",
				pushOnSuccess: true,
				pushCredentialsId: 'dim-nexus'])
		    }

		}
	}
}
