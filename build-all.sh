#!/bin/bash

NO_CACHE=false

for dir in ./*/
do
    dir=`basename ${dir%*/}`
    tag=scannerresearch/scanner-base:$dir
    docker build --no-cache=$NO_CACHE -t $tag $dir
    docker push $tag
done
