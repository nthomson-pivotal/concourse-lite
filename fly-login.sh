#!/bin/bash

set -e

fly --target local login --team-name main \
    -u admin -p admin \
    --concourse-url http://localhost:8080