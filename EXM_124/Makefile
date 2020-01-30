all: .seed-cqf-ruler synthea generate-patients calculate-patients
#all: info .setup-cqf-ruler synthea generate-patients calculate-patients

info:
	$(info `make` will cache the cqf-ruler, connectathon, and synythea setups, but repeat patient generation and calculation.)
	$(info To repeat all steps, do `make clean; make`)

#.setup-cqf-ruler: .cqf-ruler connectathon .seed-cqf-ruler
	#touch .setup-cqf-ruler

#.cqf-ruler:
	#docker run --name cqf-ruler --rm -dit -p 8080:8080 contentgroup/cqf-ruler
	#touch .cqf-ruler

#connectathon:
	#$(info connectathon checks out a specific commit SHA in case filepaths are updated)
	#git clone https://github.com/DBCG/connectathon.git
	#cd connectathon && git checkout 425795fb8dd39e213140493f22e77880a9257f00

.seed-cqf-ruler:
	until `curl --output /dev/null --silent --head --fail http://localhost:8080/cqf-ruler-r4`; do printf '.'; sleep 5; done
	curl -X POST \
  http://localhost:8080/cqf-ruler-r4/fhir \
  -H 'Content-Type: application/json' \
	-d @EXM124_FHIR4-8.2.000/EXM124_FHIR4-8.2.000-bundle.json
	touch .seed-cqf-ruler

#.seed-cqf-ruler-no-vs:
	#until `curl --output /dev/null --silent --head --fail http://localhost:8080/cqf-ruler-dstu3`; do printf '.'; sleep 5; done
	#curl -X PUT \
  #http://localhost:8080/cqf-ruler-dstu3/fhir/Measure/measure-exm124-FHIR3 \
  #-H 'Content-Type: application/json' \
	#-d @connectathon/fhir3/resources/measure/measure-EXM124_FHIR3-7.2.000.json
	#curl -X POST \
  #http://localhost:8080/cqf-ruler-dstu3/fhir \
  #-H 'Content-Type: application/json' \
	#-d @EXM124_FHIR4-8.2.000/EXM124_FHIR4-8.2.000-bundle.json
	#touch .seed-cqf-ruler-no-vs

synthea:
	git clone --single-branch --branch abacus_r4 https://github.com/projecttacoma/synthea.git

PATIENT_COUNT := 50
generate-patients:
	cd synthea && ./run_synthea -a 51-74 -g F -p $(PATIENT_COUNT) -m breast_cancer_exm124*

CQL_FILE := ./EXM124_FHIR4-8.2.000/EXM124_FHIR4-8.2.000-files/EXM124_FHIR4-8.2.000.cql
calculate-patients:
	calculate-bundles -d ./synthea/output/fhir -c $(CQL_FILE) -u http://localhost:8080/cqf-ruler-r4/fhir -s "2019-01-01" -e "2019-12-31" -m measure-EXM124-FHIR4-8.2.000

clean:
	#-docker stop cqf-ruler
	-rm -rf synthea output connectathon .cqf-ruler .seed-cqf-ruler .seed-cqf-ruler-no-vs .generate-patients .calculate-patients .setup-cqf-ruler

.PHONY: all clean info
.SECONDARY: main-build
