#!/bin/bash
set -e

if [ -z "$TIMEOUT" ]; then
  TIMEOUT="300000"
fi

if [ -z "$RAZZLE_API_PATH" ]; then
  RAZZLE_API_PATH="http://plone:8080/Plone"
fi

if [ -z "$CYPRESS_API_PATH" ]; then
  CYPRESS_API_PATH="$RAZZLE_API_PATH"
fi

if [ -z "$GIT_URL" ]; then
  GIT_URL="https://github.com"
fi

if [ -z "$GIT_BRANCH" ]; then
  GIT_BRANCH="master"
fi

if [ -z "$GIT_USER" ]; then
  GIT_USER="eea"
fi

if [ -z "$GIT_NAME" ]; then
  echo "GIT_NAME is required"
  exit 1
fi

PACKAGE="$GIT_NAME"
if [ ! -z "$NAMESPACE" ]; then
  PACKAGE="$NAMESPACE/$GIT_NAME"
fi



cd /opt/frontend/

git clone "$GIT_URL/$GIT_USER/$GIT_NAME" my-volto-project
cd my-volto-project

if [ ! -z "$GIT_CHANGE_ID" ]; then
    GIT_BRANCH=PR-${GIT_CHANGE_ID}
    git fetch origin pull/$GIT_CHANGE_ID/head:$GIT_BRANCH
fi
git checkout $GIT_BRANCH

if [ -f jsconfig.json.tpl ]; then
  cp jsconfig.json.tpl jsconfig.json
else
  if [ -f jsconfig.json.prod ]; then
    cp jsconfig.json.prod jsconfig.json
  fi
fi

mkdir -p src/addons
rm -rf src/addons/*

yarn

export NODE_ENV=test
export RAZZLE_API_PATH=$RAZZLE_API_PATH
export CYPRESS_API_PATH=$CYPRESS_API_PATH

# Run cypress
if [[ "$1" == "cypress"* ]]; then
  RAZZLE_PREFIX_PATH=/marine yarn start &
  wait-on -t $TIMEOUT http://localhost:3000
  exec ./node_modules/cypress/bin/cypress run
fi

# Run cypress with custom params
if [[ "$1" == "-"* ]]; then
  yarn start &
  wait-on -t $TIMEOUT http://localhost:3000
  exec ./node_modules/cypress/bin/cypress run "$@"
fi

exec "$@"