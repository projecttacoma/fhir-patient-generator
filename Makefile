all: .restart-cqf-ruler .update-cqf-ruler-image

info:
	$(info usage: `make MEASURE_DIR=/path/to/measure/dir VERSION=x.y.z)

.seed-cqf-ruler-no-vs:
	make -C $(MEASURE_DIR) connectathon .seed-cqf-ruler-no-vs
	touch .seed-cqf-ruler-no-vs

.run-load-script:
	until `curl --output /dev/null --silent --head --fail http://localhost:8080/cqf-ruler-dstu3`; do printf '.'; sleep 5; done
	./load-cqf-ruler.sh $(MEASURE_DIR)

.restart-cqf-ruler:
	-docker stop cqf-ruler
	docker run --name cqf-ruler --rm -dit -p 8080:8080 contentgroup/cqf-ruler:develop

.update-cqf-ruler-image: .seed-cqf-ruler-no-vs .run-load-script
	docker tag $(shell docker commit cqf-ruler) tacoma/cqf-ruler-preloaded:$(VERSION)
	docker push tacoma/cqf-ruler-preloaded:$(VERSION)

clean:
	-docker stop cqf-ruler
	-rm -rf .seed-cqf-ruler-no-vs

.PHONY: all clean info
