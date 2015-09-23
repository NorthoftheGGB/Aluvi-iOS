#!/bin/bash
dt=$(date '+%Y_%m_%d_%H_%M_%S');
git checkout dev
git tag "$dt"_release_alpha
git commit --allow-empty -m'deployment to release alpha'
git checkout release-alpha
git merge dev
git push
git checkout dev
git push --tags
