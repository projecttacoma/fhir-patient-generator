all r4: info generate-patients-r4 calculate-patients-r4

stu3: info generate-patients-stu3 calculate-patients-stu3

info:
	$(info `make` will perform patient generation and calculation.)

PATIENT_COUNT := 10
MP_START := 2020-01-01
MP_END := 2020-12-31

generate-patients-stu3:
	cd ../synthea && ./run_synthea --exporter.fhir.export=false --exporter.fhir_stu3.export=true --exporter.baseDirectory=../EXM_130/$(SYNTHEA_DIR)/ --ecqm.measurementPeriodStart=$(MP_START)T00:00:00Z -a 51-51 -p $(PATIENT_COUNT) -m EXM130*

generate-patients-r4:
	cd ../synthea && ./run_synthea --exporter.fhir.export=true --exporter.fhir_stu3.export=false --exporter.baseDirectory=../EXM_130/$(SYNTHEA_DIR)/ --ecqm.measurementPeriodStart=$(MP_START)T00:00:00Z -a 51-61 --exporter.years_of_history=11 -p $(PATIENT_COUNT) -m EXM130-r4*

calculate-patients-stu3:
	mkdir -p stu3
	cd stu3 && calculate-bundles -d ../$(SYNTHEA_DIR)/fhir_stu3 -u http://localhost:8080/cqf-ruler-dstu3/fhir -m measure-EXM130-FHIR3-7.2.000 -s $(MP_START) -e $(MP_END)

calculate-patients-r4:
	mkdir -p r4
	cd r4 && calculate-bundles -d ../$(SYNTHEA_DIR)/fhir -u http://localhost:8080/cqf-ruler-r4/fhir -m measure-EXM130-8.0.000 -s $(MP_START) -e $(MP_END)
