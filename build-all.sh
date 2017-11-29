#!/bin/bash

NO_CACHE=false
CORES=16

for dir in ./*/
do
    dir=`basename ${dir%*/}`

    tag=scannerresearch/scanner-base:$dir-gpu
    docker build --build-arg cores=$CORES \
           --no-cache=$NO_CACHE -t $tag $dir
    docker push $tag

    tag=scannerresearch/scanner-base:$dir-cpu
    docker build --build-arg cores=$CORES --build-arg cpu_only=ON \
           --no-cache=$NO_CACHE -t $tag $dir
    docker push $tag
done
