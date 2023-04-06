#!/bin/bash
#
# This script automates the building and testing of the application.
#
# Copyright (c) 2023 Open Technologies for Integration
# Licensed under the MIT license (see LICENSE for details)
#

# Exit on any failure
set -x
. $1
# Move submodule projects to the correct level to be picked up by ibmint
find ace* -name ".project" -exec dirname {} ";" | xargs -n1 -i{} echo cp -f {} .  | grep -v Test | grep -v Scaffold >> $HOME/move-projects.sh || /bin/true
cat $HOME/move-projects.sh
chmod 777 $HOME/move-projects.sh
bash $HOME/move-projects.sh


# Create the work directory
rm -rf $HOME/ace-submodule-app1-work-dir junit-reports
mqsicreateworkdir $HOME/ace-submodule-app1-work-dir

# Build everything; we can do this in this case because we want to include the unit
# tests, but production builds should specify the projects.
ibmint deploy --input-path . --output-work-directory $HOME/ace-submodule-app1-work-dir

# ibmint optimize server new for v12.0.4 - speed up test runs
ibmint optimize server --work-directory $HOME/ace-submodule-app1-work-dir --enable JVM --disable NodeJS

# Run the server to run the unit tests
IntegrationServer -w $HOME/ace-submodule-app1-work-dir --test-project App1_UnitTest --test-junit-options "--reports-dir=junit-reports"
