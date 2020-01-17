# FHIR Patient Generator

A tool for generating eCQM-specific patient data using [Synthea](https://github.com/synthetichealth/synthea)

# Prerequisites
* [Node.js](https://nodejs.org/en/)
* Install the [fhir-bundle-calculator](https://github.com/projecttacoma/fhir-bundle-calculator) command line utility:

``` bash
npm install -g fhir-bundle-calculator
```

# Usage
Each directory is named with a corresponding measure ID, and each directory contains a `Makefile` that will generate patients and sort them into their relevant populations based on the execution of the measure logic. Simply run `make` in the desired measure's directory to get the output.
