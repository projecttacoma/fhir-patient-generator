#!/bin/bash

if [ -z "$1" ]
then
    echo 'Usage: ./load-cqf-ruler.sh <measure-directory>';
    exit 1;
fi

cd $1
BASE_URL="http://localhost:8080/cqf-ruler-dstu3/fhir"
OUTPUT_DIR="output/$(ls -t 'output' | head -1)"

check_success() {
  if [ $? -ne 0 ]
  then
      echo "Error.. aborting"
      exit 1
  fi
}

echo "Using directory $OUTPUT_DIR"
echo 'Posting MeasureReport'
curl -s -X POST -H "Content-Type: application/json" --data @$OUTPUT_DIR/measure-report.json "$BASE_URL/MeasureReport" > /dev/null
check_success

echo 'Posting ipop patients for:' "$OUTPUT_DIR"
for bundle in ./$OUTPUT_DIR/ipop/*.json;
do
    echo 'Posting bundle': "$bundle";
    curl -s -X POST -H "Content-Type: application/json" --data @$bundle $BASE_URL > /dev/null
    check_success
done

echo 'Posting numerator patients for:' "$OUTPUT_DIR"
for bundle in ./$OUTPUT_DIR/numerator/*.json;
do
    echo 'Posting bundle': "$bundle";
    curl -s -X POST -H "Content-Type: application/json" --data @$bundle $BASE_URL > /dev/null
    check_success
done

echo 'Posting denominator patients for:' "$OUTPUT_DIR"
for bundle in ./$OUTPUT_DIR/denominator/*.json;
do
    echo 'Posting bundle': "$bundle";
    curl -s -X POST -H "Content-Type: application/json" --data @$bundle $BASE_URL > /dev/null
    check_success
done

echo 'Done'

