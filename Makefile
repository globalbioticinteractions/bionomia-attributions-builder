SHELL=/bin/bash
BUILD_DIR=target#!/bin/bash

BIONOMIA_ZENODO_DEPOSIT_ID=4764045
BIONOMIA_FILENAME=f393f543-89fc-46e0-bdce-e294bbb97135.zip
BIONOMIA_FILEPATH=input/$(BIONOMIA_FILENAME)

ATTRIBUTIONS_FILENAME=dist/attributions.tsv.gz

#
# Transform Bionomia Attributions Archive into terse format.
#
# derived from:
# David Shorthouse. (2021). Attributions made on Bionomia for Natural Science Collectors (Version v1) [Data set]. Zenodo. http://doi.org/10.5281/zenodo.4764045
#

.PHONY: all clean

all: $(BIONOMIA_FILEPATH) $(ATTRIBUTIONS_FILENAME)

clean:
	rm -rf input/ dist/


init:
	mkdir -p input
	mkdir -p dist

$(BIONOMIA_FILEPATH): init
	curl "https://zenodo.org/record/$(BIONOMIA_ZENODO_DEPOSIT_ID)/files/$(BIONOMIA_FILENAME)"\
 	> $(BIONOMIA_FILEPATH)
	cat $(BIONOMIA_FILEPATH)\
 	| sha256sum
	# hash://sha256/6a04c1503ca305331d833b1c463ee09bb6054c3da29cd838b44bc8e86b4b7a7f

	cat $(BIONOMIA_FILEPATH)\
 	| md5sum
	# hash://md5/2680824ab3aa25f40d040506344ef869

$(ATTRIBUTIONS_FILENAME): $(BIONOMIA_FILEPATH)
	unzip -p $(BIONOMIA_FILEPATH) occurrences.csv \
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
	 | grep -v -P "\t$"\
	 | grep -P "\t"\
	 | sed 's/\t/\tidentifiedBy\t/g'\
	 | gzip > $(ATTRIBUTIONS_FILENAME)

	cat input/occurrences_recorded_by.tsv.gz\
	 | gunzip\
	 | cut -f2,4\
	 | grep -v -P "^\t"\
	 | grep -v -P "\t$"\
	 | grep -P "\t"\
	 | sed 's/\t/\trecordedBy\t/g'\
	 | gzip >> $(ATTRIBUTIONS_FILENAME)

