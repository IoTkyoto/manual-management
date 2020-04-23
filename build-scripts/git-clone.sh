#!/bin/bash

timeout=30
command="aws configure --profile codecommit"
access_key=$CODEBUILD_ACCESS_KEY
secret_key=$CODEBUILD_SECRET_KEY
codecommit_url=$CODEBUILD_CODECOMMIT_URL

expect -c "
    set timeout ${timeout}
    spawn ${command}
    expect \"Acccess\"
    send \"${access_key}\n\"
    expect \"Secret\"
    send \"${secret_key}\n\"
    expect \"region\"
    send \"ap-northeast-1\n\"
    expect \"format\"
    send \"json\n\"
    expect \"$\"
    exit 0
"

git config --global credential.helper "!aws codecommit --profile codecommit credential-helper $@"
git config --global credential.UseHttpPath true

git clone ${codecommit_url}