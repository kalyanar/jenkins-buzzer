#!/bin/sh

############################################################
# 
# This script can be used together with the buzzer
# from http://www.f-pro.de/buzzer to trigger 
# a deployment job. The script will verify several
# Build Jobs Results before triggering the deployment job.
# This script is part of the Hackergarden @ JavaLand 2015
# 
# Requirements:
# - MacOS X incl. voices Ava and Tom
# - Jenkins as Build Server
# - Buzzer, see http://www.f-pro.de/buzzer
#
# I programmed the buzzer to react to the following keys.
# - Start Key: s
# - End Key:   e
#
# @author Marcel Birkner
#

##########################################
# Variables

JENKINS_URL=http://192.168.59.103:8080

JUNIT_JOB=junit-job
STATIC_CODE_ANALYSIS_JOB=static-code-analysis-job
ACCEPTANCE_TEST_JOB=acceptance-test-job
PROVISIONING_JOB=provisioning-job
DEPLOYMENT_JOB=deployment

##########################################
# Utility methods

speak() {
  echo "Speak as $1 -> $2"
  say -v $1 $2  
}

check() {
    echo "Checking Jenkins Job $1 for $2"
    speak ava "$2"
    result=`curl --silent -X GET $JENKINS_URL/job/$1/api/json\?pretty\=true | grep color | head -n 1`
    if [[ "$result" == *"red"* ]];
    then 
      echo "Stopping deployment - $2 - Result $result"
      speak tom "Houston, we have a problem!"
      speak ava "Stopping deployment due to problem with $2"
      exit 1
    else
      speak tom "GO"
    fi
}

##########################################
# Main App

while :
do 
    read -n 1 key
    if [[ $key = "s" ]]
    then
      echo "Starting deployment"
      speak ava "Running last deployment check now"
      
      check $JUNIT_JOB "Unit Tests"
      check $STATIC_CODE_ANALYSIS_JOB "Static Source Code Analysis"
      check $ACCEPTANCE_TEST_JOB "Acceptance Tests"
      check $PROVISIONING_JOB "Server Provisioning"
           
      speak ava "All systems have a GO"
      speak ava "Starting the deployment countdown"
      speak ava "5"
      speak ava "4" 
      speak ava "3"
      speak ava "2"
      speak ava "1"
      
      curl --silent -X POST $JENKINS_URL/job/${DEPLOYMENT_JOB}/build
      NOW=$(date +"%H %M ")
      speak ava "It is $NOW"
      speak ava "A new version of the software will now be deployed to the server"
    fi

done
