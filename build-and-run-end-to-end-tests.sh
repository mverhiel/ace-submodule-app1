#!/bin/bash
#
# This script automates the building and running of contract tests.
# It assumes that build-and-ut.sh has already been run.
#
# Copyright (c) 2023 Open Technologies for Integration
# Licensed under the MIT license (see LICENSE for details)
#

# Exit on any failure
set -x
. $1
ibmint deploy --input-path . --output-work-directory $HOME/ace-unit-test --project ${SERVICE_NAME}_EndToEndTest

# ibmint optimize server new for v12.0.4 - speed up test runs
ibmint optimize server --work-directory $HOME/ace-unit-test --enable JVM --disable NodeJS

# Run the server to run the contract tests
IntegrationServer -w $HOME/ace-unit-test --test-project ${SERVICE_NAME}_EndToEndTest --test-junit-options "--reports-dir=${HOME}/junit-reports"

