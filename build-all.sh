#!/bin/bash

for dir in ./*/
do
    dir=`basename ${dir%*/}`
    tag=wcrichto/scanner-base:$dir
    docker build -t $tag $dir
    docker push $tag
done
