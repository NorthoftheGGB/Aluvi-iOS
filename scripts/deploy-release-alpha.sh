#!/bin/bash
dt=$(date '+%d_%m_%Y_%H_%M_%S');
git tag "$dt"_release_alpha
git commit --allow-empty -m'deployment to release alpha'
git push origin head:release_alpha
git push --tags
