#!/bin/bash

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

echo "Decrypting github deploy key to publish docs"
openssl aes-256-cbc -K $encrypted_c12e6c8df1af_key -iv $encrypted_c12e6c8df1af_iv -in github_deploy_key.enc -out /tmp/deploy_rsa -d
eval "$(ssh-agent -s)"
chmod 600 /tmp/deploy_rsa
ssh-add /tmp/deploy_rsa

echo "Generating Docs"
./gradlew :spring-security-oauth2-provider:docs

echo "Publishing Documentation"
rm -rf gh-pages
git clone git@github.com:${TRAVIS_REPO_SLUG}.git -b gh-pages gh-pages --single-branch > /dev/null
cd gh-pages

# Show commands that are run
set -e

releaseDir="."
if [[ $TRAVIS_BRANCH == *".x"* ]]; then
    # If this is a versioned branch, use the versioned dir such as v3
    releaseDir="./v${TRAVIS_BRANCH:0:1}"
fi

if [[ -z "$TRAVIS_TAG" ]]; then
    releaseDir="${releaseDir}/snapshot"
else
    releaseDir="${releaseDir}/latest"

    # Also copy the release to a specific, versioned folder
    version="$TRAVIS_TAG" # eg: 3.0.1
    mkdir -p "$version"
    cp -r ../spring-security-oauth2-provider/build/docs/. "$version"
    git add "$version"
fi

# Update the documentation correctly
git rm -rf "${releaseDir}" || true
mkdir -p "${releaseDir}"
cp -r ../spring-security-oauth2-provider/build/docs/. "${releaseDir}"
git add "${releaseDir}"

cp -r ../spring-security-oauth2-provider/gh-pages-index.html ./index.html

git commit -a -m "Updating docs for Travis build: https://travis-ci.org/$TRAVIS_REPO_SLUG/builds/$TRAVIS_BUILD_ID"
git push origin HEAD

cd ..

rm -rf gh-pages
