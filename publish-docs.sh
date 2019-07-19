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

# If this is the master branch then update the snapshot
if [[ $TRAVIS_BRANCH == 'master' ]]; then
    git rm -rf snapshot/ || true
    mkdir -p snapshot
    cp -r ../spring-security-oauth2-provider/build/docs/. ./snapshot/

    git add snapshot
fi

# If there is a tag present then this becomes the latest
if [[ -n $TRAVIS_TAG ]]; then
    git rm -rf latest/ || true
    mkdir -p latest
    cp -r ../spring-security-oauth2-provider/build/docs/. ./latest/
    git add latest

    version="$TRAVIS_TAG" # eg: 3.0.1
    docVersion="v${version:0:1}" # v3

    mkdir -p "$version"
    cp -r ../spring-security-oauth2-provider/build/docs/. "./$version/"
    git add "$version"

    git rm -rf "$docVersion" || true
    cp -r ../spring-security-oauth2-provider/build/docs/. "./$docVersion/"
    git add "$docVersion"
fi

cp -r ../spring-security-oauth2-provider/gh-pages-index.html ./index.html

git commit -a -m "Updating docs for Travis build: https://travis-ci.org/$TRAVIS_REPO_SLUG/builds/$TRAVIS_BUILD_ID"
git push origin HEAD

cd ..

rm -rf gh-pages
