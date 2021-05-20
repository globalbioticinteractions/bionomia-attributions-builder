SHELL=/bin/bash
BUILD_DIR=target#!/bin/bash

BIONOMIA_ZENODO_DEPOSIT_ID=4764045
BIONOMIA_FILENAME=f393f543-89fc-46e0-bdce-e294bbb97135.zip
BIONOMIA_FILEPATH=dist/bionomia.zip

ATTRIBUTIONS_FILEPATH=dist/attributions.tsv.gz
ATTRIBUTIONS_SAMPLE_FILEPATH=dist/attributions-sample.tsv

#
# Transform Bionomia Attributions Archive into terse format.
#
# derived from:
# David Shorthouse. (2021). Attributions made on Bionomia for Natural Science Collectors (Version v1) [Data set]. Zenodo. http://doi.org/10.5281/zenodo.4764045
#

.PHONY: all clean

all: $(ATTRIBUTIONS_SAMPLE_FILEPATH)

clean:
	rm -rf input/ dist/

$(BIONOMIA_FILEPATH):
	mkdir -p input
	curl "https://zenodo.org/record/$(BIONOMIA_ZENODO_DEPOSIT_ID)/files/$(BIONOMIA_FILENAME)"\
 	> $(BIONOMIA_FILEPATH)
	cat $(BIONOMIA_FILEPATH)\
 	| sha256sum\
	| cut -d ' ' -f1 > $(BIONOMIA_FILEPATH).sha256
	# hash://sha256/6a04c1503ca305331d833b1c463ee09bb6054c3da29cd838b44bc8e86b4b7a7f

	cat $(BIONOMIA_FILEPATH)\
 	| md5sum\
	| cut -d ' ' -f1 > $(BIONOMIA_FILEPATH).md5
	# hash://md5/2680824ab3aa25f40d040506344ef869

$(ATTRIBUTIONS_FILEPATH): $(BIONOMIA_FILEPATH)
	mkdir -p dist input
	unzip -p $(BIONOMIA_FILEPATH) occurrences.csv\
	| mlr --icsv --otsv cut -f gbifID,occurrenceID\
	| gzip\
	> input/occurrences.tsv.gz

	unzip -p $(BIONOMIA_FILEPATH) attributions.csv\
	| mlr --icsv --otsv cut -f occurrence_id,identifiedBy\
	| mlr --itsv --otsv rename occurrence_id,gbifID\
	| gzip\
	> input/identified_by.tsv.gz

	unzip -p $(BIONOMIA_FILEPATH) attributions.csv\
	| mlr --icsv --otsv cut -f occurrence_id,recordedBy\
	| mlr --itsv --otsv rename occurrence_id,gbifID\
	| gzip\
	> input/recorded_by.tsv.gz

	paste  <(cat input/occurrences.tsv.gz | gunzip | tail -n+2 | sort) <(cat input/recorded_by.tsv.gz | gunzip | tail -n+2 | sort)\
 	| gzip\
 	> input/occurrences_recorded_by.tsv.gz

	paste  <(cat input/occurrences.tsv.gz | gunzip | tail -n+2 | sort) <(cat input/identified_by.tsv.gz | gunzip | tail -n+2 | sort)\
 	| gzip\
 	> input/occurrences_identified_by.tsv.gz

	cat input/occurrences_identified_by.tsv.gz\
 	| gunzip\
	| cut -f2,4\
	| grep -v -P "^\t"\
	| grep -v -P "\t$$"\
	| grep -P "\t"\
	| sed 's/\t/\tidentifiedBy\t/g'\
	| gzip > $(ATTRIBUTIONS_FILEPATH)

	cat input/occurrences_recorded_by.tsv.gz\
	| gunzip\
	| cut -f2,4\
	| grep -v -P "^\t"\
	| grep -v -P "\t$$"\
	| grep -P "\t"\
	| sed 's/\t/\trecordedBy\t/g'\
	| gzip >> $(ATTRIBUTIONS_FILEPATH)

	cat $(ATTRIBUTIONS_FILEPATH)\
	| gunzip\
	| sha256sum\
	| cut -d ' ' -f1 > dist/attributions.tsv.sha256

	cat $(ATTRIBUTIONS_FILEPATH)\
	| gunzip\
	| md5sum\
	| cut -d ' ' -f1 > dist/attributions.tsv.md5

$(ATTRIBUTIONS_SAMPLE_FILEPATH): $(ATTRIBUTIONS_FILEPATH)
	cat $(ATTRIBUTIONS_FILEPATH)\
	| gunzip\
	| head -n10 > $(ATTRIBUTIONS_SAMPLE_FILEPATH)
	cat $(ATTRIBUTIONS_FILEPATH)\
	| gunzip\
	| tail -n10 >> $(ATTRIBUTIONS_SAMPLE_FILEPATH)
