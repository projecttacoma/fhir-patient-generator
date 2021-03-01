all r4: info generate-patients calculate-patients

info:
	$(info `make` will perform patient generation and calculation.)

PATIENT_COUNT := 10
CALC_TYPE := fqm
MP_START := 2020-01-01
MP_END := 2020-12-31

ifeq ($(strip $(CALC_TYPE)),fqm)
	MEASURE_DIR_OPTS := -b ../../connectathon/fhir401/bundles/measure/EXM130-7.3.000/EXM130-7.3.000-bundle.json
endif
ifeq ($(strip $(CALC_TYPE)),http)
	MEASURE_DIR_OPTS := -u http://localhost:8080/cqf-ruler-r4/fhir -m measure-EXM130-7.3.000
endif

generate-patients:
	cd ../synthea && ./run_synthea --exporter.fhir.export=true --exporter.fhir_stu3.export=false --exporter.baseDirectory=../EXM_130-7.3.000/$(SYNTHEA_DIR)/ --ecqm.measurementPeriodStart=$(MP_START)T00:00:00Z -a 51-61 --exporter.years_of_history=11 -p $(PATIENT_COUNT) -m EXM130*

calculate-patients:
	mkdir -p r4
	cd r4 && calculate-bundles -d ../$(SYNTHEA_DIR)/fhir $(MEASURE_DIR_OPTS) -s $(MP_START) -e $(MP_END) -t $(CALC_TYPE)
