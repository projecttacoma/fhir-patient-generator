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
	./load-cqf-ruler.sh $1 FHIR_VERSION=$2;
endef

r4: .check-dependencies .setup-cqf-ruler-r4 synthea .copy-valuesets generate-patients-r4 calculate-patients-r4

stu3: .check-dependencies .setup-cqf-ruler-stu3 synthea generate-patients-stu3 calculate-patients-stu3

all all-r4: .check-dependencies .setup-cqf-ruler-r4 synthea
	$(foreach dir,$(MEASURE_DIRS),$(call gen_calc_pts,$(dir),r4))

all-stu3: .check-dependencies .setup-cqf-ruler-stu3 synthea
	$(foreach dir,$(MEASURE_DIRS),$(call gen_calc_pts,$(dir),stu3))

preload-all preload-all-r4: clean .setup-cqf-ruler-r4 .wait-cqf-ruler
	$(foreach dir,$(MEASURE_DIRS),$(call load_all_pts,$(dir),r4))

preload-all-stu3: clean .setup-cqf-ruler-stu3 .wait-cqf-ruler
	$(foreach dir,$(MEASURE_DIRS),$(call load_all_pts,$(dir),stu3))

info:
	$(info usage: `make MEASURE_DIR=/path/to/measure/dir VERSION=x.y.z)

.check-dependencies:
	npm install -g fhir-bundle-calculator

.setup-cqf-ruler-stu3: .new-cqf-ruler connectathon .seed-measures-stu3 .seed-vs-stu3
	touch .setup-cqf-ruler-stu3

.setup-cqf-ruler-r4: .new-cqf-ruler connectathon .seed-measures-r4 .seed-vs-r4
	touch .setup-cqf-ruler-r4

.new-cqf-ruler:
	docker pull contentgroup/cqf-ruler:develop
	docker run --name cqf-ruler --rm -dit -p 8080:8080 contentgroup/cqf-ruler:develop
	touch .new-cqf-ruler

connectathon:
ifeq ($(BASE_DIR),connectathon)
	$(info connectathon checks out a specific commit SHA in case filepaths are updated)
	git clone https://github.com/DBCG/connectathon.git
	cd connectathon && git checkout 77e61250343f46fec3903a7b19bc9d33bf921bd3
endif

VALUESET_FILES = $(shell find $(BASE_DIR)/fhir401/bundles -type f -name "valuesets*bundle.json")
.copy-valuesets: connectathon synthea
	cp $(VALUESET_FILES) synthea/src/main/resources/terminology
	touch .copy-valuesets

.wait-cqf-ruler:
	until `curl --output /dev/null --silent --head --fail http://localhost:8080/cqf-ruler-r4`; do printf '.'; sleep 5; done

.seed-measures-r4:
	make .wait-cqf-ruler
	# CMS 104
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Measure/measure-EXM104-9.1.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/EXM104-9.1.000/EXM104-9.1.000-files/measure-EXM104-9.1.000.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Library/library-EXM104-9.1.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/EXM104-9.1.000/EXM104-9.1.000-files/library-EXM104-9.1.000.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/EXM104-9.1.000/EXM104-9.1.000-files/library-deps-EXM104-9.1.000-bundle.json
	# CMS 105
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Measure/measure-EXM105-9.1.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/EXM105-9.1.000/EXM105-9.1.000-files/measure-EXM105-9.1.000.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Library/library-EXM105-9.1.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/EXM105-9.1.000/EXM105-9.1.000-files/library-EXM105-9.1.000.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/EXM105-9.1.000/EXM105-9.1.000-files/library-deps-EXM105-9.1.000-bundle.json
	# CMS 124
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Measure/measure-EXM124-9.0.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/EXM124-9.0.000/EXM124-9.0.000-files/measure-EXM124-9.0.000.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/EXM124-9.0.000/EXM124-9.0.000-files/library-deps-EXM124-9.0.000-bundle.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Library/library-EXM124-9.0.000 \
  		-H 'Content-Type: application/json' \
		-d @./$(BASE_DIR)/fhir401/bundles/EXM124-9.0.000/EXM124-9.0.000-files/library-EXM124-9.0.000.json
	# CMS 125
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Measure/measure-EXM125-8.0.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/EXM125-8.0.000/EXM125-8.0.000-files/measure-EXM125-8.0.000.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/EXM125-8.0.000/EXM125-8.0.000-files/library-deps-EXM125-8.0.000-bundle.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Library/library-EXM125-8.0.000 \
		-H 'Content-Type: application/json' \
		-d @./$(BASE_DIR)/fhir401/bundles/EXM125-8.0.000/EXM125-8.0.000-files/library-EXM125-8.0.000.json
	# CMS 130
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Measure/measure-EXM130-8.0.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/EXM130-8.0.000/EXM130-8.0.000-files/measure-EXM130-8.0.000.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Library/library-EXM130-8.0.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/EXM130-8.0.000/EXM130-8.0.000-files/library-EXM130-8.0.000.json 
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir/ \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/EXM130-8.0.000/EXM130-8.0.000-files/library-deps-EXM130-8.0.000-bundle.json
	# CMS 506
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Measure/measure-EXM506-3.0.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/EXM506-3.0.000/EXM506-3.0.000-files/measure-EXM506-3.0.000.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Library/library-EXM506-3.0.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/EXM506-3.0.000/EXM506-3.0.000-files/library-EXM506-3.0.000.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir/ \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/EXM506-3.0.000/EXM506-3.0.000-files/library-deps-EXM506-3.0.000-bundle.json
	touch .seed-measures-r4


.seed-vs-r4:
	make .wait-cqf-ruler
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/EXM104-9.1.000/EXM104-9.1.000-files/valuesets-EXM104-9.1.000-bundle.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/EXM105-9.1.000/EXM105-9.1.000-files/valuesets-EXM105-9.1.000-bundle.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/EXM124-9.0.000/EXM124-9.0.000-files/valuesets-EXM124-9.0.000-bundle.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/EXM125-8.0.000/EXM125-8.0.000-files/valuesets-EXM125-8.0.000-bundle.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/EXM130-8.0.000/EXM130-8.0.000-files/valuesets-EXM130-8.0.000-bundle.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir401/bundles/EXM506-3.0.000/EXM506-3.0.000-files/valuesets-EXM506-3.0.000-bundle.json
	touch .seed-vs-r4


.seed-measures-stu3:
	make .wait-cqf-ruler
	# EXM 104
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-dstu3/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir3/bundles/EXM104_FHIR3-8.1.000/EXM104_FHIR3-8.1.000-files/library-deps-EXM104_FHIR3-8.1.000-bundle.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-dstu3/fhir/Library/library-EXM104-FHIR3-8.1.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir3/bundles/EXM104_FHIR3-8.1.000/EXM104_FHIR3-8.1.000-files/library-EXM104_FHIR3-8.1.000.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-dstu3/fhir/Measure/measure-EXM104-FHIR3-8.1.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir3/bundles/EXM104_FHIR3-8.1.000/EXM104_FHIR3-8.1.000-files/measure-EXM104_FHIR3-8.1.000.json
	# EXM 105
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-dstu3/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir3/bundles/EXM105_FHIR3-8.0.000/EXM105_FHIR3-8.0.000-files/library-deps-EXM105_FHIR3-8.0.000-bundle.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-dstu3/fhir/Library/library-EXM105-FHIR3-8.0.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir3/bundles/EXM105_FHIR3-8.0.000/EXM105_FHIR3-8.0.000-files/library-EXM105_FHIR3-8.0.000.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-dstu3/fhir/Measure/measure-EXM105-FHIR3-8.0.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir3/bundles/EXM105_FHIR3-8.0.000/EXM105_FHIR3-8.0.000-files/measure-EXM105_FHIR3-8.0.000.json
	# EXM 124
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-dstu3/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir3/bundles/EXM124_FHIR3-7.2.000/EXM124_FHIR3-7.2.000-files/library-deps-EXM124_FHIR3-7.2.000-bundle.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-dstu3/fhir/Library/library-EXM124-FHIR3-7.2.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir3/bundles/EXM124_FHIR3-7.2.000/EXM124_FHIR3-7.2.000-files/library-EXM124_FHIR3-7.2.000.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-dstu3/fhir/Measure/measure-EXM124-FHIR3-7.2.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir3/bundles/EXM124_FHIR3-7.2.000/EXM124_FHIR3-7.2.000-files/measure-EXM124_FHIR3-7.2.000.json
	# EXM 125
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-dstu3/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir3/bundles/EXM125_FHIR3-7.2.000/EXM125_FHIR3-7.2.000-files/library-deps-EXM125_FHIR3-7.2.000-bundle.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-dstu3/fhir/Library/library-EXM125-FHIR3-7.2.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir3/bundles/EXM125_FHIR3-7.2.000/EXM125_FHIR3-7.2.000-files/library-EXM125_FHIR3-7.2.000.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-dstu3/fhir/Measure/measure-EXM125-FHIR3-7.2.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir3/bundles/EXM125_FHIR3-7.2.000/EXM125_FHIR3-7.2.000-files/measure-EXM125_FHIR3-7.2.000.json
	# EXM 130
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-dstu3/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir3/bundles/EXM130_FHIR3-7.2.000/EXM130_FHIR3-7.2.000-files/library-deps-EXM130_FHIR3-7.2.000-bundle.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-dstu3/fhir/Library/library-EXM130-FHIR3-7.2.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir3/bundles/EXM130_FHIR3-7.2.000/EXM130_FHIR3-7.2.000-files/library-EXM130_FHIR3-7.2.000.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X PUT http://localhost:8080/cqf-ruler-dstu3/fhir/Measure/measure-EXM130-FHIR3-7.2.000 \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir3/bundles/EXM130_FHIR3-7.2.000/EXM130_FHIR3-7.2.000-files/measure-EXM130_FHIR3-7.2.000.json
	touch .seed-measures-stu3
	
.seed-vs-stu3:
	make .wait-cqf-ruler
	until `curl --output /dev/null --silent --head --fail http://localhost:8080/cqf-ruler-dstu3`; do printf '.'; sleep 5; done
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-dstu3/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir3/bundles/EXM104_FHIR3-8.1.000/EXM104_FHIR3-8.1.000-files/valuesets-EXM104_FHIR3-8.1.000-bundle.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-dstu3/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir3/bundles/EXM105_FHIR3-8.0.000/EXM105_FHIR3-8.0.000-files/valuesets-EXM105_FHIR3-8.0.000-bundle.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-dstu3/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir3/bundles/EXM124_FHIR3-7.2.000/EXM124_FHIR3-7.2.000-files/valuesets-EXM124_FHIR3-7.2.000-bundle.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-dstu3/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir3/bundles/EXM125_FHIR3-7.2.000/EXM125_FHIR3-7.2.000-files/valuesets-EXM125_FHIR3-7.2.000-bundle.json
	curl -s -o /dev/null -w "Response Code: %{http_code}\n" -X POST http://localhost:8080/cqf-ruler-dstu3/fhir \
		-H 'Content-Type: application/json' \
		-d @$(BASE_DIR)/fhir3/bundles/EXM130_FHIR3-7.2.000/EXM130_FHIR3-7.2.000-files/valuesets-EXM130_FHIR3-7.2.000-bundle.json
	touch .seed-vs-stu3

synthea:
	git clone --single-branch --branch abacus https://github.com/projecttacoma/synthea.git

PATIENT_COUNT := 10
generate-patients-stu3:
	make -C $(MEASURE_DIR) generate-patients-stu3

calculate-patients-stu3:
	make -C $(MEASURE_DIR) calculate-patients-stu3

generate-patients-r4:
	make -C $(MEASURE_DIR) generate-patients-r4

calculate-patients-r4:
	make -C $(MEASURE_DIR) calculate-patients-r4

preload-stu3: clean .new-cqf-ruler connectathon .seed-measures-stu3 .run-load-script-stu3

preload-r4: clean .new-cqf-ruler connectathon .seed-measures-r4 .run-load-script-r4

.run-load-script-stu3: .wait-cqf-ruler
	FHIR_VERSION=stu3 ./load-cqf-ruler.sh $(MEASURE_DIR)

.run-load-script-r4: .wait-cqf-ruler
	./load-cqf-ruler.sh $(MEASURE_DIR) FHIR_VERSION=r4

.update-cqf-ruler-image:
	./release-docker-image.sh $(VERSION)

clean:
	-docker stop cqf-ruler
	-rm -rf synthea/output
	-rm -rf EXM_*/synthea_output
	-rm .setup-cqf-ruler-stu3
	-rm .setup-cqf-ruler-r4
	-rm .new-cqf-ruler
	-rm .seed-measures-stu3
	-rm .seed-measures-r4
	-rm .seed-vs-stu3
	-rm .seed-vs-r4
	-rm .copy-valuesets

.PHONY: all clean info .wait-cqf-ruler
