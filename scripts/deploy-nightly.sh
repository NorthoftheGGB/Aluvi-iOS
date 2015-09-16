#!/bin/bash
dt=$(date '+%d_%m_%Y_%H_%M_%S');
git tag "$dt"
git commit --allow-empty -m'deployment to master branch'
git push origin head:master
git push --tags
