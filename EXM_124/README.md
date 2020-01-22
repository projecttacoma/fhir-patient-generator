# Steps to recreate patients.

The makefile contained in this directory contains automated ways of recreating
these patients. It assumes you have `docker`, `curl`, and `calculate-bundles` (from
this repository) installed and configured already

To recreate the generation, run `make`. Optionally pass in the number of
patients you wish to create to override the default of 10 patients:
```
make PATIENT_COUNT=20
```

Refer to the Makefile for individual
steps if you need to repeat a particular one one-at-a-time. This will put the
results in the ./output/ directory

The `patients` directory contains FHIR STU3 bundles of sample patients for
EXM124, placed in the directory of the population they are in for CQL
calculation.  Note that for EXM124, Denominator is equal to Initial Population,
so there are no patients in the Initial Population but not the Denominator.

The `patch` directory contains modifications to `synthea` that were made in
order to accomodate this measure.


## Changes Made To Sythea:
`synthea.properites` changed to only export stu3 with 2 years of history:
<img width="1034" alt="image" src="https://user-images.githubusercontent.com/14879344/69961205-5da87000-14d9-11ea-97a8-696e751c8015.png">

Pap Test Observation added (relevant to Cervical Cancer measure):
<img width="842" alt="image" src="https://user-images.githubusercontent.com/14879344/69961277-8892c400-14d9-11ea-9969-f5e82206c367.png">

Mammography Diagnostic Report added:
<img width="589" alt="image" src="https://user-images.githubusercontent.com/14879344/69961331-a52efc00-14d9-11ea-9565-282278c254ca.png">

Transition modified to make a path. to Diagnostic Report:
<img width="585" alt="image" src="https://user-images.githubusercontent.com/14879344/69961378-bb3cbc80-14d9-11ea-85e7-a5e3903019e4.png">

Transition probabilities modified to make it more likely to be relevant to measure:
<img width="610" alt="image" src="https://user-images.githubusercontent.com/14879344/69961423-d4de0400-14d9-11ea-95fe-597a20d4d076.png">
