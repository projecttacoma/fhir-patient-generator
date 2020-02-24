#!/bin/bash

if [ -z "$1" ]
then
    echo 'Usage: ./load-cqf-ruler.sh <measure-directory>';
    exit 1;
fi

cd $1

BASE_URL="http://localhost:8080/cqf-ruler-r4/fhir"

if [ $FHIR_VERSION == "stu3" ]
then
    BASE_URL="http://localhost:8080/cqf-ruler-dstu3/fhir"
    OUTPUT_DIR="stu3"
else
    OUTPUT_DIR="r4"
fi

# In the event that there are multiple results output folders,
# just use the most recent one
OUTPUT_DIR="$OUTPUT_DIR/output/$(ls -t $OUTPUT_DIR/output | head -1)"
echo "Using directory $OUTPUT_DIR"

check_success() {
  if [ $? -ne 0 ]
  then
      echo "Error.. aborting"
      exit 1
  fi
}

curl -s -o /dev/null -w "%{http_code}\n" -X POST -H "Content-Type: application/json" --data @$OUTPUT_DIR/measure-report.json "$BASE_URL/MeasureReport"
check_success

echo 'Posting ipop patients for:' "$OUTPUT_DIR"
for bundle in ./$OUTPUT_DIR/ipop/*.json;
do
    echo 'Posting bundle': "$bundle";
    curl -s -o /dev/null -w "%{http_code}\n" -X POST -H "Content-Type: application/json" --data @$bundle $BASE_URL
    check_success
done

echo 'Posting numerator patients for:' "$OUTPUT_DIR"
for bundle in ./$OUTPUT_DIR/numerator/*.json;
do
    echo 'Posting bundle': "$bundle";
    curl -s -o /dev/null -w "%{http_code}\n" -X POST -H "Content-Type: application/json" --data @$bundle $BASE_URL
    check_success
done

echo 'Posting denominator patients for:' "$OUTPUT_DIR"
for bundle in ./$OUTPUT_DIR/denominator/*.json;
do
    echo 'Posting bundle': "$bundle";
    curl -s -o /dev/null -w "%{http_code}\n" -X POST -H "Content-Type: application/json" --data @$bundle $BASE_URL
    check_success
done

echo 'Done'

