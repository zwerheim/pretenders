#!/bin/bash
# Documentation for publishing a new version, in executable format

set -e
FILE="pretenders/__init__.py"
REALFILE=$FILE

# Test (dry) mode does not do any harm
if [ "$1" == "-t" ]
then
    shopt -s expand_aliases
    alias git='echo $ git'
    alias python='echo $ python'
    alias sh='echo $ sh'
    REALFILE="/dev/stdout"
    shift
fi

if [ "$1" == "" ]
then
    echo "Usage: $0 [-t] version"
    echo "    -t  run in test mode, i.e. not updating anything"
    exit -1
fi

echo "I assume you ran your tests all right..."
VERSION=$1

echo -e "\nUpdating master with develop..."
git checkout master
git pull --rebase origin develop

echo -e "\nIncreasing version number to $VERSION in $FILE..."
cat - > $REALFILE  <<EOF
# Do not edit, this file is auto-generated by publish.sh
__version__ = '$VERSION'
EOF

git add $FILE
git commit -m "Bumped version number to $VERSION"

echo -e "\nTagging and pushing to Github..."
git tag $VERSION
git push origin master
git push --tags

echo -e "\nUploading to PyPI..."
python setup.py sdist upload

echo -e "\nTriggering a build of the documentation at RTD..."
sh ./rtdocs.sh

echo -e "\nDone! Wasn't it nice and easy? :)"