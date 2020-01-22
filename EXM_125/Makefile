all: info .setup-cqf-ruler synthea generate-patients calculate-patients

info:
	$(info `make` will cache the cqf-ruler, connectathon, and synythea setups, but repeat patient generation and calculation.)
	$(info To repeat all steps, do `make clean; make`)

.setup-cqf-ruler: .cqf-ruler connectathon .seed-cqf-ruler
	touch .setup-cqf-ruler

.cqf-ruler:
	docker run --name cqf-ruler --rm -dit -p 8080:8080 contentgroup/cqf-ruler
	touch .cqf-ruler

connectathon:
	$(info connectathon checks out a specific commit SHA in case filepaths are updated)
	git clone https://github.com/DBCG/connectathon.git
	cd connectathon && git checkout 425795fb8dd39e213140493f22e77880a9257f00

.seed-cqf-ruler:
	until `curl --output /dev/null --silent --head --fail http://localhost:8080/cqf-ruler-dstu3`; do printf '.'; sleep 5; done
	curl -X POST \
  http://localhost:8080/cqf-ruler-dstu3/fhir/Measure \
  -H 'Content-Type: application/json' \
	-d @connectathon/fhir3/resources/measure/measure-EXM125_FHIR3-7.2.000.json
	curl -X POST \
  http://localhost:8080/cqf-ruler-dstu3/fhir \
  -H 'Content-Type: application/json' \
	-d @connectathon/fhir3/resources/library/all-libraries-bundle.json
	curl -X POST \
  http://localhost:8080/cqf-ruler-dstu3/fhir \
  -H 'Content-Type: application/json' \
	-d @connectathon/fhir3/resources/valuesets/valuesets-EXM125_FHIR3-7.2.000.json
	touch .seed-cqf-ruler

synthea:
	git clone --single-branch --branch abacus https://github.com/projecttacoma/synthea.git

PATIENT_COUNT := 10
generate-patients:
	cd synthea && ./run_synthea -a 52-52 -g F -p $(PATIENT_COUNT) -m EXM125*

CQL_FILE := EXM125_FHIR3-7.2.000.cql
calculate-patients:
	calculate-bundles -d ./synthea/output/fhir_stu3 -c $(CQL_FILE) -u http://localhost:8080/cqf-ruler-dstu3/fhir

clean:
	-docker stop cqf-ruler
	-rm -rf synthea output connectathon .cqf-ruler .seed-cqf-ruler .generate-patients .calculate-patients .setup-cqf-ruler

.PHONY: all clean info