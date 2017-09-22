#!/bin/bash

fly -t lite set-pipeline -p iot_dashboard -c ci/pipeline.yml -l ci/credentials.yml
