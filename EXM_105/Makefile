all stu3: info generate-patients-stu3 calculate-patients-stu3

info:
	$(info `make` will perform patient generation and calculation.)

PATIENT_COUNT := 30
generate-patients-stu3:
	cd ../synthea && ./run_synthea -a 18-21 -p $(PATIENT_COUNT) -m stroke_exm_105

CQL_FILE := ../../connectathon/fhir3/bundles/EXM105_FHIR3-8.0.000/EXM105_FHIR3-8.0.000-files/EXM105_FHIR3-8.0.000.cql
calculate-patients-stu3:
	mkdir -p stu3
	cd stu3 && calculate-bundles -d ../../synthea/output/fhir_stu3 -c $(CQL_FILE) -u http://localhost:8080/cqf-ruler-dstu3/fhir --measure-id measure-EXM105-FHIR3-8.0.000
