all r4: info generate-patients-r4 calculate-patients-r4

stu3: info generate-patients-stu3 calculate-patients-stu3

info:
	$(info `make` will perform patient generation and calculation.)

PATIENT_COUNT := 10

generate-patients-stu3:
	cd ../synthea && ./run_synthea --exporter.fhir.export=false --exporter.fhir_stu3.export=true --exporter.baseDirectory=../EXM_124/$(SYNTHEA_DIR)/ -a 52-52 -g F -p $(PATIENT_COUNT) -m breast_cancer_exm124*

generate-patients-r4:
	cd ../synthea && ./run_synthea --exporter.fhir.export=true --exporter.fhir_stu3.export=false --exporter.baseDirectory=../EXM_124/$(SYNTHEA_DIR)/ -a 52-52 -g F -p $(PATIENT_COUNT) -m breast_cancer_exm124-r4*

calculate-patients-stu3:
	mkdir -p stu3
	cd stu3 && calculate-bundles -d ../$(SYNTHEA_DIR)/fhir_stu3 -u http://localhost:8080/cqf-ruler-dstu3/fhir -m measure-EXM124-FHIR3-7.2.000

calculate-patients-r4:
	mkdir -p r4
	cd r4 && calculate-bundles -d ../$(SYNTHEA_DIR)/fhir -u http://localhost:8080/cqf-ruler-r4/fhir -m measure-EXM124-FHIR4-8.2.000
