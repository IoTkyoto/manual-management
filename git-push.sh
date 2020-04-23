#!/bin/bash

timeout=30
command="git push origin master"
user_name=$CODEBUILD_USER_NAME
git_url=$CODEBUILD_GIT_URL
access_token=$CODEBUILD_ACCESS_TOKEN

git remote set-url origin $git_url

echo "change url"

expect -c "
    set timeout ${timeout}
    spawn ${command}
    expect \"UserName\"
    send \"${user_name}\n\"
    expect \"Password\"
    send \"${access_token}\n\"
    expect \"$\"
    exit 0
"