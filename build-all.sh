#!/bin/bash

for dir in ./*/
do
    dir=`basename ${dir%*/}`
    tag=scannerresearch/scanner-base:$dir
    docker build -t $tag $dir
    docker push $tag
done
