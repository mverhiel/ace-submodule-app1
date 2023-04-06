pipeline {
  agent any
  parameters {
    /* These values would be better moved to a configuration file and provided by */
    /* the Config File Provider plugin (or equivalent), but this is good enough   */
    /* for a demo of ACE pipelines that isn't intended as a Jenkins tutorial.     */
    string(name: 'ACE_HOST',   defaultValue: '127.0.0.1', description: 'Integration node REST API host or IP address')
    string(name: 'ACE_PORT',   defaultValue: '4414', description: 'Integration node REST API port')
    string(name: 'ACE_SERVER',   defaultValue: 'IS01', description: 'Integration server name')
	string(name: 'SERVICE_NAME',   description: 'service name being built and deployed')
  }
  environment {
    LICENSE = 'accept'
	MQSIPROFILE = '/opt/IBM/ace-12.0.8.0/server/bin/mqsiprofile'
  }

  stages {
    stage('Build and UT') {
      steps {
        sh  '''#!/bin/bash
		    set -x
            # Set HOME to somewhere writable by Junit
			echo $
            export HOME=/tmp/$SERVICE_NAME
			mkdir -p $HOME

            # Clean up just in case files have been left around
            rm -f */junit-reports/TEST*.xml
            rm -rf $PWD/ace-server
    
            ./build-and-ut.sh $MQSIPROFILE 
            '''

      }
      post {
        always {
            junit '**/junit-reports/TEST*.xml'
        }
      }
    }

    stage('EndToEnd Tests') {
      steps {
        sh  '''#!/bin/bash
		    set -x
            # Set HOME to somewhere writable by Junit
            export HOME=/tmp/$SERVICE_NAME

            # Clean up just in case files have been left around
            rm -f */junit-reports/TEST*.xml
            rm -rf $PWD/ace-server

            ./build-and-run-end-to-end-tests.sh $MQSIPROFILE
            '''

      }
      post {
        always {
            junit '**/junit-reports/TEST*.xml'
        }
      }
    }

    stage('Next stage BAR build') {
      steps {
         sh  '''#!/bin/bash
		   set -x
		   . $MQSIPROFILE
           # Build a single BAR file that contains everything rather than deploying multiple BAR files.
           # Deploying multiple BAR files (for the shared libraries and the application) would work,
	       # but would take longer on redeploys due to reloading the application on each deploy.
           #
           # Tekton pipelines don't have this issue because the application and library are unpacked
	       # into a work directory in a container image in that pipeline, so there is no deploy to a
	       # running server.
	       export SHLIBS=`find */library.descriptor -exec dirname {} ";" | xargs -n1 -i{} echo -y {} | xargs echo`
	       echo "Including libraries: $SHLIBS"
           mqsipackagebar -w $PWD -a $HOME/demo-application-combined.bar -k App1 $SHLIBS

           # Optional compile for XMLNSC, DFDL, and map resources. Useful as long as the target 
           # broker is the same OS, CPU, and installation including ifixes as the build system.
           # mqsibar --bar-file demo-application-combined.bar --compile
            '''
      }
    }

    stage('Next stage deploy') {
      steps {
        sh '''#!/bin/bash
		  set -x 
		  . $MQSIPROFILE 
		  mqsideploy -i $ACE_HOST -p $ACE_PORT -e $ACE_SERVER -a $HOME/demo-application-combined.bar
		  '''
      }
    }

  }
}
