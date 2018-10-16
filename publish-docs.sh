#!/bin/bash
set -e

echo "Generating Docs"

./gradlew :spring-security-oauth2-provider:docs || EXIT_STATUS=$?

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global credential.helper "store --file=~/.git-credentials"
echo "https://$GITHUB_TOKEN:@github.com" > ~/.git-credentials


echo "Publishing Documentation"

git clone https://${GITHUB_TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git -b gh-pages gh-pages --single-branch > /dev/null
cd gh-pages

# If this is the master branch then update the snapshot
if [[ $TRAVIS_BRANCH == 'master' ]]; then
    mkdir -p snapshot
    cp -r ../build/docs/manual/. ./snapshot/

    git add snapshot/*
fi

# If there is a tag present then this becomes the latest
if [[ -n $TRAVIS_TAG ]]; then
    git rm -rf latest/
    mkdir -p latest
    cp -r ../plugin/build/docs/. ./latest/
    git add latest/*

    version="$TRAVIS_TAG" # eg: v3.0.1
    version=${version:1} # 3.0.1
    majorVersion=${version:0:4} # 3.0.
    majorVersion="${majorVersion}x" # 3.0.x

    mkdir -p "$version"
    cp -r ../plugin/build/docs/. "./$version/"
    git add "$version/*"

    git rm -rf "$majorVersion"
    cp -r ../plugin/build/docs/. "./$majorVersion/"
    git add "$majorVersion/*"
fi

cp -r ../build/docs/index.html ./index.html

git commit -a -m "Updating docs for Travis build: https://travis-ci.org/$TRAVIS_REPO_SLUG/builds/$TRAVIS_BUILD_ID"
git push origin HEAD

cd ..

rm -rf gh-pages