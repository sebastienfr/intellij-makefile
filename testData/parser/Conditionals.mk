clean:
ifeq ($(BUILD_TYPE),QA)
	python make.py --clean data/area_of_interest.poly
else
	rm -rf dependencies
endif