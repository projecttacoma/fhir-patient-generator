all: .restart-cqf-ruler .run-load-script .update-cqf-ruler-image

info:
	$(info usage: `make MEASURE_DIR=/path/to/measure/dir VERSION=x.y.z)

.seed-cqf-ruler-no-vs:
	cd $(MEASURE_DIR)
	make connectathon .seed-cqf-ruler-no-vs

.run-load-script:
	until `curl --output /dev/null --silent --head --fail http://localhost:8080/cqf-ruler-dstu3`; do printf '.'; sleep 5; done
	./load-cqf-ruler.sh $(MEASURE_DIR)

.restart-cqf-ruler:
	docker stop cqf-ruler || true && docker run --name cqf-ruler --rm -dit -p 8080:8080 contentgroup/cqf-ruler:develop

.update-cqf-ruler-image:
	docker tag $(shell docker commit cqf-ruler) tacoma/cqf-ruler-preloaded:$(VERSION)
	docker push tacoma/cqf-ruler-preloaded:$(VERSION)

clean:
	docker stop cqf-ruler

.PHONY: all clean info
