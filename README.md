# FHIR Patient Generator

A tool for generating eCQM-specific patient data using [Synthea&trade;](https://github.com/synthetichealth/synthea)

###### Table of Contents

* [Prerequisites](#prerequisites)
* [Developer Quickstart](#developer-quickstart)
  * [Installation](#installation)
  * [Usage](#usage)
  * [Examples](#examples)
* [Generation and Calculation](#generation-and-calculation)
* [Existing Patient Data](#existing-patient-data)
* [Pre-loading a Docker Image](#pre-loading-a-docker-image)

## Prerequisites
* [Node.js >=10.15.1](https://nodejs.org/en/)
* [Docker](https://www.docker.com/)
* [fhir-bundle-calculator](https://github.com/projecttacoma/fhir-bundle-calculator#installation-with-npm) command line utility

## Developer Quickstart

**NOTE**: This tool is only compatible with `fhir-bundle-calculator` version 3.0.0 or higher:

``` bash
npm install -g fhir-bundle-calculator
calculate-bundles --version
# should ouput 3.x.x
```

### Installation

``` bash
git clone https://github.com/projecttacoma/fhir-patient-generator
cd fhir-patient-generator
```

### Usage

``` bash
make MEASURE_DIR=/path/to/measure/dir <r4|stu3>
```

`MEASURE_DIR` is the relative path to the directory in `fhir-patient-generator` for the desired measure. Currently supported measures:

* EXM_104
* EXM_105
* EXM_124
* EXM_125
* EXM_130

#### Examples

``` bash
# Generate R4 patient data for EXM130
make MEASURE_DIR=EXM_130 r4

# Generate stu3 patient data for EXM130
make MEASURE_DIR=EXM_130 stu3
```

## Generation and Calculation

The `Makefile` in `fhir-patient-generator` consolidates the following dependencies and links them together to eventually output patient data along with calculation statistics.

* [Abacus Synthea Fork](https://github.com/projecttacoma/synthea): Used for generating measure-specific patient data
* [cqf-ruler](https://github.com/DBCG/cqf-ruler): Used for running calculation and getting MeasureReport resources
* [Connectathon repository](https://github.com/DBCG/connectathon): Used for loading cqf-ruler with needed ValueSet, Library, and Measure resources
* [fhir-bundle-calculator](https://github.com/projecttacoma/fhir-bundle-calculator): Command line utility for requesting and interpreting calculation results

The following diagram depicts the operations that each utility is responsible for and the order in which they are executed:

![Sequence Diagram](https://mermaid.ink/img/eyJjb2RlIjoic2VxdWVuY2VEaWFncmFtXG5wYXJ0aWNpcGFudCBTIGFzIFN5bnRoZWFcbnBhcnRpY2lwYW50IGZwZyBhcyBmaGlyLXBhdGllbnQtZ2VuZXJhdG9yXG5wYXJ0aWNpcGFudCBmYmMgYXMgZmhpci1idW5kbGUtY2FsY3VsYXRvclxucGFydGljaXBhbnQgQyBhcyBjcWYtcnVsZXJcblxuZnBnIC0-PiBDOiBzdGFydCBkb2NrZXIgY29udGFpbmVyXG5mcGcgLT4-IEM6IFBPU1QgVmFsdWVTZXQsIExpYnJhcnksIE1lYXN1cmUgcmVzb3VyY2VzXG5mcGcgLT4-IFM6IGdlbmVyYXRlIG1lYXN1cmUtc3BlY2lmaWMgcGF0aWVudHNcblMgLT4-IFM6IHdyaXRlIEZISVIgYnVuZGxlcyB0byBvdXRwdXQgZGlyZWN0b3J5XG5mcGcgLT4-IGZiYzogcnVuIGNhbGN1bGF0aW9uIG9uIGJ1bmRsZXMgaW4gU3ludGhlYSBvdXRwdXQgZGlyZWN0b3J5XG5cbmxvb3AgZm9yIGVhY2ggYnVuZGxlXG5mYmMgLT4-IEM6IFBPU1QgYnVuZGxlXG5DIC0-PiBmYmM6IHJlc3BvbmQgd2l0aCBjcmVhdGVkIHJlc291cmNlc1xuZmJjIC0-PiBmYmM6IHBhcnNlIHJlc3BvbnNlIGZvciBwYXRpZW50IElEXG5mYmMgLT4-IEM6IEdFVCAvJGV2YWx1YXRlLW1lYXN1cmUgZm9yIHBhdGllbnRcbkMgLT4-IGZiYzogcmVzcG9uZCB3aXRoIGluZGl2aWR1YWwgTWVhc3VyZVJlcG9ydFxuZmJjIC0-PiBmcGc6IHdyaXRlIE1lYXN1cmVSZXBvcnQgdG8gZGlza1xuXG5hbHQgaXMgbnVtZXJhdG9yXG5mYmMgLT4-IGZwZzogd3JpdGUgYnVuZGxlIHRvIFwibnVtZXJhdG9yXCIgZGlyZWN0b3J5XG5lbHNlIGlzIGRlbm9taW5hdG9yXG5mYmMgLT4-IGZwZzogd3JpdGUgYnVuZGxlIHRvIFwiZGVub21pbmF0b3JcIiBkaXJlY3RvcnlcbmVsc2UgaXMgaW5pdGlhbCBwb3B1bGF0aW9uXG5mYmMgLT4-IGZwZzogd3JpdGUgYnVuZGxlIHRvIFwiaXBvcFwiIGRpcmVjdG9yeVxuZWxzZSBpcyBubyBwb3B1bGF0aW9uXG5mYmMgLT4-IGZwZzogd3JpdGUgYnVuZGxlIHRvIFwibm9uZVwiIGRpcmVjdG9yeVxuZW5kXG5lbmRcblxuZmJjIC0-PiBDOiBHRVQgLyRldmFsdWF0ZS1tZWFzdXJlIGZvciBhbGwgcGF0aWVudHNcbkMgLT4-IGZiYzogcmVzcG9uZCB3aXRoIHBhdGllbnQtbGlzdCBNZWFzdXJlUmVwb3J0XG5mYmMgLT4-IGZwZzogd3JpdGUgcGF0aWVudC1saXN0IE1lYXN1cmVSZXBvcnQgdG8gZGlza1xuIiwibWVybWFpZCI6eyJ0aGVtZSI6ImRlZmF1bHQifX0)

## Existing Patient Data

We have published patient data for all supported measures in both `R4` and `STU3`, which can be found in the `<measure-directory>/patients-r4` and `<measure-directory>/patients-stu3` for all supported measures.

## Pre-loading a Docker Image

`fhir-patient-generator` also supports loading and tagging a Docker image with patient data for a specific measure, not including ValueSets. This image will be published to the [Tacoma Docker organization](https://hub.docker.com/r/tacoma/cqf-ruler-preloaded/tags)

``` bash
make MEASURE_DIR=/path/to/measure/dir VERSION=x.y.z preload-<r4|stu3>
```

This command will tag and push `tacoma/cqf-ruler-preloaded:x.y.z` to Dockerhub.

### Examples

``` bash
# Publish preloaded image with EXM130 R4 data under tag 1.0.0
make MEASURE_DIR=EXM_130 VERSION=1.0.0 preload-r4

# Publish preloaded image with EXM130 STU3 data under tag 1.0.0
make MEASURE_DIR=EXM_130 VERSION=1.0.0 preload-stu3
```
