all r4: info generate-patients-r4 calculate-patients-r4

info:
	$(info `make` will perform patient generation and calculation.)

PATIENT_COUNT := 10
MP_START := 2019-01-01
MP_END := 2019-12-31

generate-patients-r4:
	cd ../synthea && ./run_synthea --exporter.fhir.export=true --exporter.fhir_stu3.export=false --exporter.baseDirectory=../EXM_111-9.1.000/$(SYNTHEA_DIR)/ -p $(PATIENT_COUNT) --ecqm.measurementPeriodStart=$(MP_START)T00:00:00Z -m EXM111*

calculate-patients-r4:
	mkdir -p r4
	cd r4 && calculate-bundles -d ../$(SYNTHEA_DIR)/fhir -u http://localhost:8080/cqf-ruler-r4/fhir -m measure-EXM111-9.1.000 -s $(MP_START) -e $(MP_END)
