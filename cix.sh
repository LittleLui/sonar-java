#!/bin/bash
set -euo pipefail
echo "Running $TEST with SQ=$SQ_VERSION"

export JAVA_HOME=/opt/sonarsource/jvm/java-1.9.0-sun-x64
export PATH=$JAVA_HOME/bin:$PATH

case "$TEST" in
  ruling)
    if [[ $GITHUB_BRANCH == "PULLREQUEST-"* && $SLAVE != "windows" ]] || [[ $GITHUB_BRANCH != "PULLREQUEST-"* && $SLAVE == "windows" ]]
    then
      #Ruling on linux for MASTER branch only (not PR)
      #Ruling on windows for internal PRs only (not MASTER branch)
      exit 0;
    fi
    #fetch submodule containing sources of ruling projects
    git submodule update --init --recursive
  ;;
  performancing)
    #fetch submodule containing sources of performancing projects
    git submodule update --init --recursive
  ;;
  plugin)
  ;;
  semantic)
    #fetch submodule containing sources of projects used for semantic ITs
    git submodule update --init --recursive
  ;;
  *)
    echo "Unexpected TEST mode: $TEST"
    exit 1
  ;;
esac
cd its/$TEST
mvn package -Pit-$TEST -Dsonar.runtimeVersion="$SQ_VERSION" -Dmaven.test.redirectTestOutputToFile=false \
  -Dversion.enforcer.plugin=3.0.0-M1 -Dversion.jar.plugin=3.0.2 \
  -B -e -V
