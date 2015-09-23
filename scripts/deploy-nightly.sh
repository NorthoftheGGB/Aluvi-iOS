#!/bin/bash
dt=$(date '+%d_%m_%Y_%H_%M_%S');
git checkout dev
git tag "$dt"_nightly
git commit --allow-empty -m'deployment to master branch'
git checkout master
git merge dev
git push
git checkout dev
git push --tags
