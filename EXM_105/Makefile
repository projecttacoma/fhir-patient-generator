all r4: info generate-patients-r4 calculate-patients-r4

stu3: info generate-patients-stu3 calculate-patients-stu3

info:
	$(info `make` will perform patient generation and calculation.)

PATIENT_COUNT := 10
SYNTHEA_PROPS := ../synthea/src/main/resources/synthea.properties

generate-patients-stu3:
	sed 's/exporter.fhir.export = true/exporter.fhir.export = false/g' $(SYNTHEA_PROPS) > temp
	sed 's/exporter.fhir_stu3.export = false/exporter.fhir_stu3.export = true/g' temp > $(SYNTHEA_PROPS)
	rm -rf temp
	cd ../synthea && ./run_synthea -a 18-21 -p $(PATIENT_COUNT) -m stroke_exm_105*

generate-patients-r4:
	sed 's/exporter.fhir.export = false/exporter.fhir.export = true/g' $(SYNTHEA_PROPS) > temp
	sed 's/exporter.fhir_stu3.export = true/exporter.fhir_stu3.export = false/g' temp > $(SYNTHEA_PROPS)
	rm -rf temp
	cd ../synthea && ./run_synthea -a 19-21 -p $(PATIENT_COUNT) -m stroke_exm_105_r4*

calculate-patients-stu3:
	mkdir -p stu3
	cd stu3 && calculate-bundles -d ../../synthea/output/fhir_stu3 -u http://localhost:8080/cqf-ruler-dstu3/fhir --measure-id measure-EXM105-FHIR3-8.0.000 -s "2018-01-01" -e "2018-12-31"

calculate-patients-r4:
	mkdir -p r4
	cd r4 && calculate-bundles -d ../../synthea/output/fhir -c ../../connectathon/fhir4/cql/EXM105_FHIR4-8.1.000.cql -u http://localhost:8080/cqf-ruler-r4/fhir -s "2019-01-01" -e "2019-12-31" -m measure-EXM105-FHIR4-8.1.000
