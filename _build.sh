#!/bin/bash
set -e

# configure your name and email if you have not done so
git config --global user.email "zheng.bangyou@gmail.com"
git config --global user.name "Bangyou Zheng"
git clone --branch=gh-pages \
  https://${GH_TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git \
  site-output
cd site-output

git pull --no-edit origin master

if [[ $(git diff --name-only HEAD~1 | grep "sensitivity.apsimx\|_parameter.yml\|_build.sh") ]]; then
    sudo apt-get install -y mono-complete
else
    echo "no files found"
fi


Rscript _generate-gh-pages.R
git add -A --ignore-errors .
git diff --quiet --exit-code --cached || git commit -m "Update the website"
git push

pwd
