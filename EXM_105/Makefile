all: info .setup-cqf-ruler synthea generate-patients calculate-patients

info:
	$(info `make` will cache the cqf-ruler, connectathon, and synythea setups, but repeat patient generation and calculation.)
	$(info To repeat all steps, do `make clean; make`)

.setup-cqf-ruler: .cqf-ruler connectathon .seed-cqf-ruler
	touch .setup-cqf-ruler

.cqf-ruler:
	docker run --name cqf-ruler --rm -dit -p 8080:8080 contentgroup/cqf-ruler:develop
	touch .cqf-ruler

connectathon:
	git clone https://github.com/DBCG/connectathon.git

.seed-cqf-ruler:
	until `curl --output /dev/null --silent --head --fail http://localhost:8080/cqf-ruler-dstu3`; do printf '.'; sleep 5; done
	curl -X POST \
  http://localhost:8080/cqf-ruler-dstu3/fhir \
  -H 'Content-Type: application/json' \
	-d @connectathon/fhir3/bundles/EXM105_FHIR3-8.0.000/EXM105_FHIR3-8.0.000-bundle.json

synthea:
	git clone --single-branch --branch abacus --depth 1 https://github.com/projecttacoma/synthea.git

PATIENT_COUNT := 30
generate-patients:
	cd synthea && ./run_synthea -a 18-21 -p $(PATIENT_COUNT) -m stroke_exm_105

CQL_FILE := connectathon/fhir3/bundles/EXM105_FHIR3-8.0.000/EXM105_FHIR3-8.0.000-files/EXM105_FHIR3-8.0.000.cql
calculate-patients:
	calculate-bundles -d ./synthea/output/fhir_stu3 -c $(CQL_FILE) -u http://localhost:8080/cqf-ruler-dstu3/fhir

clean:
	-docker stop cqf-ruler
	-rm -rf synthea output connectathon .cqf-ruler .seed-cqf-ruler .generate-patients .calculate-patients .setup-cqf-ruler

.PHONY: all clean info
