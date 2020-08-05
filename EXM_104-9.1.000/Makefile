all r4: info generate-patients-r4 calculate-patients-r4

stu3: info generate-patients-stu3 calculate-patients-stu3

info:
	$(info `make` will perform patient generation and calculation.)

PATIENT_COUNT := 10
MP_START := 2020-01-01
MP_END := 2020-12-31

generate-patients-stu3:
	cd ../synthea && ./run_synthea --exporter.fhir.export=false --exporter.fhir_stu3.export=true --exporter.baseDirectory=../EXM_104-9.1.000/$(SYNTHEA_DIR)/ -a 18-21 -p $(PATIENT_COUNT) -m stroke_exm_104*

generate-patients-r4:
	cd ../synthea && ./run_synthea --exporter.fhir.export=true --exporter.fhir_stu3.export=false --exporter.baseDirectory=../EXM_104-9.1.000/$(SYNTHEA_DIR)/ -a 19-21 -p $(PATIENT_COUNT) -m stroke_exm_104_r4*

calculate-patients-stu3:
	mkdir -p stu3
	cd stu3 && calculate-bundles -d ../$(SYNTHEA_DIR)/fhir_stu3 -u http://localhost:8080/cqf-ruler-dstu3/fhir -m measure-EXM104-FHIR3-8.1.000 -s $(MP_START) -e $(MP_END)

calculate-patients-r4:
	mkdir -p r4
	cd r4 && calculate-bundles -d ../$(SYNTHEA_DIR)/fhir -u http://localhost:8080/cqf-ruler-r4/fhir -m measure-EXM104-9.1.000 -s $(MP_START) -e $(MP_END)
