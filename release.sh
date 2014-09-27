#!/bin/bash

REPO_NAME=$1

if [ -z "$REPO_NAME" ]; then
    printf "Please enter repository name: "
    read REPO_NAME < /dev/tty
fi

STAGING_NAME=$REPO_NAME-staging

hg clone https://bitbucket.org/zyeeda/$REPO_NAME
hg clone $REPO_NAME $STAGING_NAME

cd $STAGING_NAME
hg flow develop
mvn release:prepare -Darguments="-DskipTests"
mvn release:perform -Darguments="-DskipTests" -Pinternal-release

hg flow master
hg merge $(hg log -l 5 | grep changeset | awk '{print $2}' | sed -n '2p' | cut -d':' -f2)
hg commit -m "Merge"

hg push

cd ../$REPO_NAME
hg push

cd ..

printf "Done!"

