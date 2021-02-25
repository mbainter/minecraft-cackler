#!/bin/bash

aws ssm get-parameter --name /shared/minecraft/restic/password --with-decryption | jq -rM '.Parameter.Value'
