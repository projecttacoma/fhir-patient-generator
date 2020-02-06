all: info .setup-cqf-ruler synthea generate-patients calculate-patients

r4: info .setup-cqf-ruler-r4 synthea generate-patients-r4 calculate-patients-r4

info:
	$(info `make` will cache the cqf-ruler, connectathon, and synythea setups, but repeat patient generation and calculation.)
	$(info To repeat all steps, do `make clean; make`)

.setup-cqf-ruler: .cqf-ruler connectathon .seed-cqf-ruler
	touch .setup-cqf-ruler

.setup-cqf-ruler-r4: .cqf-ruler connectathon .seed-cqf-ruler-r4
	touch .setup-cqf-ruler-r4

.cqf-ruler:
	docker run --name cqf-ruler --rm -dit -p 8080:8080 contentgroup/cqf-ruler
	touch .cqf-ruler

connectathon:
	git clone https://github.com/DBCG/connectathon.git

.seed-cqf-ruler:
	until `curl --output /dev/null --silent --head --fail http://localhost:8080/cqf-ruler-dstu3`; do printf '.'; sleep 5; done
	curl -X POST \
  http://localhost:8080/cqf-ruler-dstu3/fhir \
  -H 'Content-Type: application/json' \
	-d @connectathon/fhir3/bundles/EXM124_FHIR3-7.2.000/EXM124_FHIR3-7.2.000-bundle.json
	touch .seed-cqf-ruler

.seed-cqf-ruler-r4:
	until `curl --output /dev/null --silent --head --fail http://localhost:8080/cqf-ruler-r4`; do printf '.'; sleep 5; done
	curl -X POST \
  http://localhost:8080/cqf-ruler-r4/fhir \
  -H 'Content-Type: application/json' \
	-d @connectathon/fhir4/bundles/EXM124_FHIR4-8.2.000/EXM124_FHIR4-8.2.000-bundle.json
	touch .seed-cqf-ruler-r4

.seed-cqf-ruler-no-vs:
	until `curl --output /dev/null --silent --head --fail http://localhost:8080/cqf-ruler-dstu3`; do printf '.'; sleep 5; done
	curl -X PUT \
  http://localhost:8080/cqf-ruler-dstu3/fhir/Measure/measure-EXM124-FHIR3-7.2.000 \
  -H 'Content-Type: application/json' \
	-d @connectathon/fhir3/bundles/EXM124_FHIR3-7.2.000/EXM124_FHIR3-7.2.000-files/measure-EXM124_FHIR3-7.2.000.json
	curl -X POST \
  http://localhost:8080/cqf-ruler-dstu3/fhir \
  -H 'Content-Type: application/json' \
	-d @connectathon/fhir3/bundles/EXM124_FHIR3-7.2.000/EXM124_FHIR3-7.2.000-files/library-deps-EXM124_FHIR3-7.2.000-bundle.json
	curl -X PUT \
  http://localhost:8080/cqf-ruler-dstu3/fhir/Library/library-EXM124-FHIR3-7.2.000 \
  -H 'Content-Type: application/json' \
	-d @connectathon/fhir3/bundles/EXM124_FHIR3-7.2.000/EXM124_FHIR3-7.2.000-files/library-EXM124_FHIR3-7.2.000.json
	touch .seed-cqf-ruler-no-vs

.seed-cqf-ruler-no-vs-r4:
	until `curl --output /dev/null --silent --head --fail http://localhost:8080/cqf-ruler-r4`; do printf '.'; sleep 5; done
	curl -X PUT \
  http://localhost:8080/cqf-ruler-r4/fhir/Measure/measure-EXM124-FHIR4-8.2.000 \
  -H 'Content-Type: application/json' \
	-d @connectathon/fhir4/bundles/EXM124_FHIR4-8.2.000/EXM124_FHIR4-8.2.000-files/measure-EXM124_FHIR4-8.2.000.json
	curl -X POST \
  http://localhost:8080/cqf-ruler-r4/fhir \
  -H 'Content-Type: application/json' \
	-d @connectathon/fhir4/bundles/EXM124_FHIR4-8.2.000/EXM124_FHIR4-8.2.000-files/library-deps-EXM124_FHIR4-8.2.000-bundle.json
	curl -X PUT \
  http://localhost:8080/cqf-ruler-r4/fhir/Library/library-EXM124-FHIR4-8.2.000 \
  -H 'Content-Type: application/json' \
	-d @./connectathon/fhir4/bundles/EXM124_FHIR4-8.2.000/EXM124_FHIR4-8.2.000-files/library-EXM124_FHIR4-8.2.000.json
	touch .seed-cqf-ruler-no-vs-r4

synthea:
	git clone --single-branch --branch abacus https://github.com/projecttacoma/synthea.git

PATIENT_COUNT := 10
SYNTHEA_PROPS := synthea/src/main/resources/synthea.properties

generate-patients:
	sed 's/exporter.fhir.export = true/exporter.fhir.export = false/g' $(SYNTHEA_PROPS) > temp
	sed 's/exporter.fhir_stu3.export = false/exporter.fhir_stu3.export = true/g' temp > $(SYNTHEA_PROPS)
	rm -rf temp
	cd synthea && ./run_synthea -a 52-52 -g F -p $(PATIENT_COUNT) -m breast_cancer_exm124*

generate-patients-r4:
	sed 's/exporter.fhir.export = false/exporter.fhir.export = true/g' $(SYNTHEA_PROPS) > temp
	sed 's/exporter.fhir_stu3.export = true/exporter.fhir_stu3.export = false/g' temp > $(SYNTHEA_PROPS)
	rm -rf temp
	cd synthea && ./run_synthea -a 52-52 -g F -p $(PATIENT_COUNT) -m breast_cancer_exm124-r4*

calculate-patients:
	calculate-bundles -d ./synthea/output/fhir_stu3 -c ./connectathon/fhir3/bundles/EXM124_FHIR3-7.2.000/EXM124_FHIR3-7.2.000-files/EXM124_FHIR3-7.2.000.cql -u http://localhost:8080/cqf-ruler-dstu3/fhir -m measure-EXM124-FHIR3-7.2.000

calculate-patients-r4:
	calculate-bundles -d ./synthea/output/fhir -c ./connectathon/fhir4/bundles/EXM124_FHIR4-8.2.000/EXM124_FHIR4-8.2.000-files/EXM124_FHIR4-8.2.000.cql -u http://localhost:8080/cqf-ruler-r4/fhir -m measure-EXM124-FHIR4-8.2.000

clean:
	-docker stop cqf-ruler
	-rm -rf synthea output connectathon .cqf-ruler .seed-cqf-ruler .seed-cqf-ruler-r4 .seed-cqf-ruler-no-vs .seed-cqf-ruler-no-vs-r4 .generate-patients .generate-patients-r4 .setup-cqf-ruler .setup-cqf-ruler-r4 temp

.PHONY: all clean info
