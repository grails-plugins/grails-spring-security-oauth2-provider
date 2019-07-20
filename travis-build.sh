#!/bin/bash
set -e

echo "TRAVIS_TAG          : $TRAVIS_TAG"
echo "TRAVIS_BRANCH       : $TRAVIS_BRANCH"
echo "TRAVIS_PULL_REQUEST : $TRAVIS_PULL_REQUEST"
echo "Publishing archives for branch $TRAVIS_BRANCH"

# Clean workspace
rm -rf build docs target gh-pages spring-security-oauth2-provider/build || true

# Stop gradle daemon (if it is running) since it doesn't work well on travis
./gradlew --stop
#TODO Fix integration tests, maybe using the acceptanceTest task?
#./gradlew clean check assemble
./gradlew clean test assemble

if [[ -n ${TRAVIS_TAG} ]] || [[ ${TRAVIS_BRANCH} == 'master' && ${TRAVIS_PULL_REQUEST} == 'false' ]]; then
    echo "Publishing archives for branch $TRAVIS_BRANCH"

    if [[ -n ${TRAVIS_TAG} ]]; then
        echo "Pushing build to Bintray"
        ./gradlew :spring-security-oauth2-provider:bintrayUpload
    else
        echo "Publishing snapshot..."
        ./gradlew :spring-security-oauth2-provider:publish
    fi
fi

# Only publish docs if it's not a pull request
if [[ ${TRAVIS_PULL_REQUEST} == 'false' ]]; then
    ./publish-docs.sh
fi

