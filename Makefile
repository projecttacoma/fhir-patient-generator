MEASURE_DIRS := $(shell ls -d EXM_*)
export SYNTHEA_DIR := synthea_output/$(shell date +%Y-%m-%dT%H%M%S)

define gen_calc_pts
	make -C $1 $2;
endef

define load_all_pts
	./load-cqf-ruler.sh $1 FHIR_VERSION=$2;
endef

r4: .check-dependencies .setup-cqf-ruler-r4 synthea generate-patients-r4 calculate-patients-r4

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
	$(info connectathon checks out a specific commit SHA in case filepaths are updated)
	git clone https://github.com/DBCG/connectathon.git
	cd connectathon && git checkout 52084217d33a9d9fc8d79664a535edb24557635b

.wait-cqf-ruler:
	until `curl --output /dev/null --silent --head --fail http://localhost:8080/cqf-ruler-r4`; do printf '.'; sleep 5; done

.seed-measures-r4:
	make .wait-cqf-ruler
	# CMS 104
	curl -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Measure/measure-EXM104-FHIR4-8.1.000 \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir4/bundles/EXM104_FHIR4-8.1.000/EXM104_FHIR4-8.1.000-files/measure-EXM104_FHIR4-8.1.000.json
	curl -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Library/library-EXM104-FHIR4-8.1.000 \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir4/bundles/EXM104_FHIR4-8.1.000/EXM104_FHIR4-8.1.000-files/library-EXM104_FHIR4-8.1.000.json
	curl -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir4/bundles/EXM104_FHIR4-8.1.000/EXM104_FHIR4-8.1.000-files/library-deps-EXM104_FHIR4-8.1.000-bundle.json
	# CMS 105
	curl -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Measure/measure-EXM105-FHIR4-8.1.000 \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir4/bundles/EXM105_FHIR4-8.1.000/EXM105_FHIR4-8.1.000-files/measure-EXM105_FHIR4-8.1.000.json
	curl -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Library/library-EXM105-FHIR4-8.1.000 \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir4/bundles/EXM105_FHIR4-8.1.000/EXM105_FHIR4-8.1.000-files/library-EXM105_FHIR4-8.1.000.json
	curl -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir4/bundles/EXM105_FHIR4-8.1.000/EXM105_FHIR4-8.1.000-files/library-deps-EXM105_FHIR4-8.1.000-bundle.json
	# CMS 124
	curl -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Measure/measure-EXM124-FHIR4-8.2.000 \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir4/bundles/EXM124_FHIR4-8.2.000/EXM124_FHIR4-8.2.000-files/measure-EXM124_FHIR4-8.2.000.json
	curl -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir4/bundles/EXM124_FHIR4-8.2.000/EXM124_FHIR4-8.2.000-files/library-deps-EXM124_FHIR4-8.2.000-bundle.json
	curl -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Library/library-EXM124-FHIR4-8.2.000 \
  		-H 'Content-Type: application/json' \
		-d @./connectathon/fhir4/bundles/EXM124_FHIR4-8.2.000/EXM124_FHIR4-8.2.000-files/library-EXM124_FHIR4-8.2.000.json
	# CMS 125
	curl -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Measure/measure-EXM125-FHIR4-7.2.000 \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir4/bundles/EXM125_FHIR4-7.2.000/EXM125_FHIR4-7.2.000-files/measure-EXM125_FHIR4-7.2.000.json
	curl -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir4/bundles/EXM125_FHIR4-7.2.000/EXM125_FHIR4-7.2.000-files/library-deps-EXM125_FHIR4-7.2.000-bundle.json
	curl -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Library/library-EXM125-FHIR4-7.2.000 \
		-H 'Content-Type: application/json' \
		-d @./connectathon/fhir4/bundles/EXM125_FHIR4-7.2.000/EXM125_FHIR4-7.2.000-files/library-EXM125_FHIR4-7.2.000.json
	# CMS 130
	curl -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Measure/measure-EXM130-FHIR4-7.2.000 \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir4/bundles/EXM130_FHIR4-7.2.000/EXM130_FHIR4-7.2.000-files/measure-EXM130_FHIR4-7.2.000.json
	curl -X PUT http://localhost:8080/cqf-ruler-r4/fhir/Library/library-EXM130-FHIR4-7.2.000 \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir4/bundles/EXM130_FHIR4-7.2.000/EXM130_FHIR4-7.2.000-files/library-EXM130_FHIR4-7.2.000.json 
	curl -X POST http://localhost:8080/cqf-ruler-r4/fhir/ \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir4/bundles/EXM130_FHIR4-7.2.000/EXM130_FHIR4-7.2.000-files/library-deps-EXM130_FHIR4-7.2.000-bundle.json
	touch .seed-measures-r4


.seed-vs-r4:
	make .wait-cqf-ruler
	curl -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir4/bundles/EXM104_FHIR4-8.1.000/EXM104_FHIR4-8.1.000-files/valuesets-EXM104_FHIR4-8.1.000-bundle.json
	curl -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir4/bundles/EXM105_FHIR4-8.1.000/EXM105_FHIR4-8.1.000-files/valuesets-EXM105_FHIR4-8.1.000-bundle.json
	curl -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir4/bundles/EXM124_FHIR4-8.2.000/EXM124_FHIR4-8.2.000-files/valuesets-EXM124_FHIR4-8.2.000-bundle.json
	curl -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir4/bundles/EXM125_FHIR4-7.2.000/EXM125_FHIR4-7.2.000-files/valuesets-EXM125_FHIR4-7.2.000-bundle.json
	curl -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir4/bundles/EXM130_FHIR4-7.2.000/EXM130_FHIR4-7.2.000-files/valuesets-EXM130_FHIR4-7.2.000-bundle.json
	curl -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir4/bundles/EXM124_FHIR4-8.2.000/EXM124_FHIR4-8.2.000-files/valuesets-EXM124_FHIR4-8.2.000-bundle.json
	curl -X POST http://localhost:8080/cqf-ruler-r4/fhir \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir4/bundles/EXM124_FHIR4-8.2.000/EXM124_FHIR4-8.2.000-files/valuesets-EXM124_FHIR4-8.2.000-bundle.json
	touch .seed-vs-r4


.seed-measures-stu3:
	make .wait-cqf-ruler
	# EXM 104
	curl -X POST http://localhost:8080/cqf-ruler-dstu3/fhir \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir3/bundles/EXM104_FHIR3-8.1.000/EXM104_FHIR3-8.1.000-files/library-deps-EXM104_FHIR3-8.1.000-bundle.json
	curl -X PUT http://localhost:8080/cqf-ruler-dstu3/fhir/Library/library-EXM104-FHIR3-8.1.000 \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir3/bundles/EXM104_FHIR3-8.1.000/EXM104_FHIR3-8.1.000-files/library-EXM104_FHIR3-8.1.000.json
	curl -X PUT http://localhost:8080/cqf-ruler-dstu3/fhir/Measure/measure-EXM104-FHIR3-8.1.000 \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir3/bundles/EXM104_FHIR3-8.1.000/EXM104_FHIR3-8.1.000-files/measure-EXM104_FHIR3-8.1.000.json
	# EXM 105
	curl -X POST http://localhost:8080/cqf-ruler-dstu3/fhir \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir3/bundles/EXM105_FHIR3-8.0.000/EXM105_FHIR3-8.0.000-files/library-deps-EXM105_FHIR3-8.0.000-bundle.json
	curl -X PUT http://localhost:8080/cqf-ruler-dstu3/fhir/Library/library-EXM105-FHIR3-8.0.000 \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir3/bundles/EXM105_FHIR3-8.0.000/EXM105_FHIR3-8.0.000-files/library-EXM105_FHIR3-8.0.000.json
	curl -X PUT http://localhost:8080/cqf-ruler-dstu3/fhir/Measure/measure-EXM105-FHIR3-8.0.000 \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir3/bundles/EXM105_FHIR3-8.0.000/EXM105_FHIR3-8.0.000-files/measure-EXM105_FHIR3-8.0.000.json
	# EXM 124
	curl -X POST http://localhost:8080/cqf-ruler-dstu3/fhir \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir3/bundles/EXM124_FHIR3-7.2.000/EXM124_FHIR3-7.2.000-files/library-deps-EXM124_FHIR3-7.2.000-bundle.json
	curl -X PUT http://localhost:8080/cqf-ruler-dstu3/fhir/Library/library-EXM124-FHIR3-7.2.000 \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir3/bundles/EXM124_FHIR3-7.2.000/EXM124_FHIR3-7.2.000-files/library-EXM124_FHIR3-7.2.000.json
	curl -X PUT http://localhost:8080/cqf-ruler-dstu3/fhir/Measure/measure-EXM124-FHIR3-7.2.000 \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir3/bundles/EXM124_FHIR3-7.2.000/EXM124_FHIR3-7.2.000-files/measure-EXM124_FHIR3-7.2.000.json
	# EXM 125
	curl -X POST http://localhost:8080/cqf-ruler-dstu3/fhir \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir3/bundles/EXM125_FHIR3-7.2.000/EXM125_FHIR3-7.2.000-files/library-deps-EXM125_FHIR3-7.2.000-bundle.json
	curl -X PUT http://localhost:8080/cqf-ruler-dstu3/fhir/Library/library-EXM125-FHIR3-7.2.000 \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir3/bundles/EXM125_FHIR3-7.2.000/EXM125_FHIR3-7.2.000-files/library-EXM125_FHIR3-7.2.000.json
	curl -X PUT http://localhost:8080/cqf-ruler-dstu3/fhir/Measure/measure-EXM125-FHIR3-7.2.000 \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir3/bundles/EXM125_FHIR3-7.2.000/EXM125_FHIR3-7.2.000-files/measure-EXM125_FHIR3-7.2.000.json
	# EXM 130
	curl -X POST http://localhost:8080/cqf-ruler-dstu3/fhir \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir3/bundles/EXM130_FHIR3-7.2.000/EXM130_FHIR3-7.2.000-files/library-deps-EXM130_FHIR3-7.2.000-bundle.json
	curl -X PUT http://localhost:8080/cqf-ruler-dstu3/fhir/Library/library-EXM130-FHIR3-7.2.000 \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir3/bundles/EXM130_FHIR3-7.2.000/EXM130_FHIR3-7.2.000-files/library-EXM130_FHIR3-7.2.000.json
	curl -X PUT http://localhost:8080/cqf-ruler-dstu3/fhir/Measure/measure-EXM130-FHIR3-7.2.000 \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir3/bundles/EXM130_FHIR3-7.2.000/EXM130_FHIR3-7.2.000-files/measure-EXM130_FHIR3-7.2.000.json
	touch .seed-measures-stu3
	
.seed-vs-stu3:
	make .wait-cqf-ruler
	until `curl --output /dev/null --silent --head --fail http://localhost:8080/cqf-ruler-dstu3`; do printf '.'; sleep 5; done
	curl -X POST http://localhost:8080/cqf-ruler-dstu3/fhir \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir3/bundles/EXM104_FHIR3-8.1.000/EXM104_FHIR3-8.1.000-files/valuesets-EXM104_FHIR3-8.1.000-bundle.json
	curl -X POST http://localhost:8080/cqf-ruler-dstu3/fhir \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir3/bundles/EXM105_FHIR3-8.0.000/EXM105_FHIR3-8.0.000-files/valuesets-EXM105_FHIR3-8.0.000-bundle.json
	curl -X POST http://localhost:8080/cqf-ruler-dstu3/fhir \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir3/bundles/EXM124_FHIR3-7.2.000/EXM124_FHIR3-7.2.000-files/valuesets-EXM124_FHIR3-7.2.000-bundle.json
	curl -X POST http://localhost:8080/cqf-ruler-dstu3/fhir \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir3/bundles/EXM125_FHIR3-7.2.000/EXM125_FHIR3-7.2.000-files/valuesets-EXM125_FHIR3-7.2.000-bundle.json
	curl -X POST http://localhost:8080/cqf-ruler-dstu3/fhir \
		-H 'Content-Type: application/json' \
		-d @connectathon/fhir3/bundles/EXM130_FHIR3-7.2.000/EXM130_FHIR3-7.2.000-files/valuesets-EXM130_FHIR3-7.2.000-bundle.json
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

.PHONY: all clean info .wait-cqf-ruler
