#!/bin/bash
# loads all bundles in a given folder

if [ -z "$1" ]
then
    echo 'Usage: ./load-existing-patients.sh <bundle-directory>';
    exit 1;
fi

cd $1
BASE_URL="http://localhost:8080/cqf-ruler-r4/fhir"

check_success() {
  if [ $? -ne 0 ]
  then
      echo "Error.. aborting"
      exit 1
  fi
}

for bundle in ./*.json;
do
    echo 'Posting bundle': "$bundle";
    curl -s -o /dev/null -w "%{http_code}\n" -X POST -H "Content-Type: application/json" --data @$bundle $BASE_URL
    check_success
done