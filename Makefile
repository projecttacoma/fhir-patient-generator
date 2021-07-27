MEASURE_DIRS := $(shell ls -d EXM_*)
export SYNTHEA_DIR := synthea_output/$(shell date +%Y-%m-%dT%H%M%S)
BASE_DIR := ..
ifeq ($(strip $(CI_TOOL)),)
	BASE_DIR := connectathon
endif
ifeq ($(strip $(CI_TOOL)),false)
	BASE_DIR := connectathon
endif

define gen_calc_pts
	make -C $1 $2;
endef

define load_all_pts
	./load-cqf-ruler.sh $1;
endef

r4: .check-dependencies .setup-cqf-ruler synthea .copy-valuesets generate-patients calculate-patients

all all-r4: .check-dependencies .setup-cqf-ruler synthea
	$(foreach dir,$(MEASURE_DIRS),$(call gen_calc_pts,$(dir)))

preload-all: clean .setup-cqf-ruler .wait-cqf-ruler
	$(foreach dir,$(MEASURE_DIRS),$(call load_all_pts,$(dir)))

info:
	$(info usage: `make MEASURE_DIR=/path/to/measure/dir VERSION=x.y.z CALC_TYPE=<fqm/http>`)

.check-dependencies:
	npm install -g fhir-bundle-calculator

.setup-cqf-ruler: .new-cqf-ruler connectathon .seed-measures .seed-vs
	touch .setup-cqf-ruler

.new-cqf-ruler:
	docker pull contentgroup/cqf-ruler:latest
	docker run --name cqf-ruler --rm -dit -p 8080:8080 contentgroup/cqf-ruler:latest
	touch .new-cqf-ruler

connectathon:
ifeq ($(BASE_DIR),connectathon)
	$(info connectathon checks out a specific commit SHA in case filepaths are updated)
	git clone https://github.com/DBCG/connectathon.git
	cd connectathon && git checkout 4be117b59939bb204711fea2018534ce0cb58c71
endif

VALUESET_FILES = $(shell find $(BASE_DIR)/fhir401/bundles -type f -name "valuesets*bundle.json")
.copy-valuesets: connectathon synthea
	cp $(VALUESET_FILES) synthea/src/main/resources/terminology
	touch .copy-valuesets

.wait-cqf-ruler:
	until `curl --output /dev/null --silent --head --fail http://localhost:8080/cqf-ruler-r4`; do printf '.'; sleep 5; done

.seed-measures:
	make .wait-cqf-ruler
	# CMS 104
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Measure/measure-EXM104-8.2.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM104-8.2.000/EXM104-8.2.000-files/measure-EXM104-8.2.000.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Library/library-EXM104-8.2.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM104-8.2.000/EXM104-8.2.000-files/library-EXM104-8.2.000.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM104-8.2.000/EXM104-8.2.000-files/library-deps-EXM104-8.2.000-bundle.json
	# CMS 105
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Measure/measure-EXM105-8.2.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM105-8.2.000/EXM105-8.2.000-files/measure-EXM105-8.2.000.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Library/library-EXM105-8.2.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM105-8.2.000/EXM105-8.2.000-files/library-EXM105-8.2.000.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM105-8.2.000/EXM105-8.2.000-files/library-deps-EXM105-8.2.000-bundle.json
	# CMS 124
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Measure/measure-EXM124-9.0.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM124-9.0.000/EXM124-9.0.000-files/measure-EXM124-9.0.000.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM124-9.0.000/EXM124-9.0.000-files/library-deps-EXM124-9.0.000-bundle.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Library/library-EXM124-9.0.000 \
  		-H 'Content-Type: application/json' \
		-d @./$(BASE_DIR)/fhir401/bundles/measure/EXM124-9.0.000/EXM124-9.0.000-files/library-EXM124-9.0.000.json
	# CMS 125
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Measure/measure-EXM125-7.3.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM125-7.3.000/EXM125-7.3.000-files/measure-EXM125-7.3.000.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM125-7.3.000/EXM125-7.3.000-files/library-deps-EXM125-7.3.000-bundle.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Library/library-EXM125-7.3.000 \
		-H 'Content-Type: application/json' \
		-d @./$(BASE_DIR)/fhir401/bundles/measure/EXM125-7.3.000/EXM125-7.3.000-files/library-EXM125-7.3.000.json
	# CMS 130
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Measure/measure-EXM130-7.3.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM130-7.3.000/EXM130-7.3.000-files/measure-EXM130-7.3.000.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Library/library-EXM130-7.3.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM130-7.3.000/EXM130-7.3.000-files/library-EXM130-7.3.000.json 
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir/ \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM130-7.3.000/EXM130-7.3.000-files/library-deps-EXM130-7.3.000-bundle.json
	# CMS 506
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Measure/measure-EXM506-2.2.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM506-2.2.000/EXM506-2.2.000-files/measure-EXM506-2.2.000.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Library/library-EXM506-2.2.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM506-2.2.000/EXM506-2.2.000-files/library-EXM506-2.2.000.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir/ \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM506-2.2.000/EXM506-2.2.000-files/library-deps-EXM506-2.2.000-bundle.json
	# CMS 111
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Measure/measure-EXM111-9.1.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM111-9.1.000/EXM111-9.1.000-files/measure-EXM111-9.1.000.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Library/library-EXM111-9.1.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM111-9.1.000/EXM111-9.1.000-files/library-EXM111-9.1.000.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir/ \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM111-9.1.000/EXM111-9.1.000-files/library-deps-EXM111-9.1.000-bundle.json
	touch .seed-measures

.seed-vs:
	make .wait-cqf-ruler
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM104-8.2.000/EXM104-8.2.000-files/valuesets-EXM104-8.2.000-bundle.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM105-8.2.000/EXM105-8.2.000-files/valuesets-EXM105-8.2.000-bundle.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM124-9.0.000/EXM124-9.0.000-files/valuesets-EXM124-9.0.000-bundle.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM125-7.3.000/EXM125-7.3.000-files/valuesets-EXM125-7.3.000-bundle.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM130-7.3.000/EXM130-7.3.000-files/valuesets-EXM130-7.3.000-bundle.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM506-2.2.000/EXM506-2.2.000-files/valuesets-EXM506-2.2.000-bundle.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/measure/EXM111-9.1.000/EXM111-9.1.000-files/valuesets-EXM111-9.1.000-bundle.json
	touch .seed-vs

synthea:
	git clone --single-branch --branch abacus-dev https://github.com/projecttacoma/synthea.git

PATIENT_COUNT := 10
CALC_TYPE := fqm
generate-patients:
	make -C $(MEASURE_DIR) generate-patients

calculate-patients:
	make -C $(MEASURE_DIR) calculate-patients

preload: clean .new-cqf-ruler connectathon .seed-measures .run-load-script

.run-load-script: .wait-cqf-ruler
	./load-cqf-ruler.sh $(MEASURE_DIR) FHIR_VERSION=r4

.update-cqf-ruler-image:
	./release-docker-image.sh $(VERSION)

clean:
	-docker stop cqf-ruler
	-rm -rf EXM_*/synthea_output
	-rm .setup-cqf-ruler-stu3
	-rm .setup-cqf-ruler-r4
	-rm .setup-cqf-ruler
	-rm .new-cqf-ruler
	-rm .seed-measures-stu3
	-rm .seed-measures-r4
	-rm .seed-measures
	-rm .seed-vs-stu3
	-rm .seed-vs-r4
	-rm .seed-vs
	-rm .copy-valuesets

deep-clean: clean
	-rm -rf synthea
	-rm -rf connectathon

.PHONY: all clean info .wait-cqf-ruler
