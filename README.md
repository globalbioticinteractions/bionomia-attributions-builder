# bionomia-attributions-builder
Creates a terse biodiversity data attributions based on [Bionomia](https://bionomia.net) archive:

David Shorthouse. (2021). Attributions made on Bionomia for Natural Science Collectors (Version v1) [Data set]. Zenodo. http://doi.org/10.5281/zenodo.4764045



Generated attributions table for occurrence ids are formatted like:

[occurrence id]{tab}[attribution type name]{tab}[person id]

for example:

```
http://arctos.database.museum/guid/MSB:Host:15730?seid=2593587	identifiedBy	https://orcid.org/0000-0003-4738-5967
http://arctos.database.museum/guid/MSB:Host:15731?seid=2593588	identifiedBy	https://orcid.org/0000-0003-4738-5967
LD:General:1001542	identifiedBy	http://www.wikidata.org/entity/Q86532
NRM:NRM-Fish:16167	identifiedBy	http://www.wikidata.org/entity/Q446239
```

# Requirements

 * [make](https://en.wikipedia.org/wiki/Make_(software)) 
 * [bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell))
 * [mlr](https://github.com/johnkerl/miller)
 * sha256sum / md5sum 
 * internet connection

# Usage
The generate an attributions.tsv.gz and associated digital artifacts, run:

```shell
$ make BIONOMIA_ZENODO_DEPOSIT_ID=[some other zenodo deposit id]
```

where BIONOMIA_ZENODO_DEPOSIT_ID is set to the deposit id of the Bionomia archive (e.g., 4764045 for deposit at http://doi.org/10.5281/zenodo.4764045).


$ ls -1 dist
attributions-sample.tsv
attributions.tsv.gz
attributions.tsv.md5
attributions.tsv.sha256
bionomia.zip.sha256
bionomia.zip.md5
bionomia.zip
```

where generated ```dist/``` directory includes:

 * attributions-sample.tsv:  the first and last 10 lines uncompressed lines from attributions.tsv.gz 
 * [file].sha256 [file].md5 files contain sha256 and md5 hex-encoded hashes of related files
 * bionomia.zip was the bionomia archive used to generated the attributions.

# Provenance

To generate a machine-readable location-agonistic provenance, run:

```
$ make prov ATTRIBUTIONS_ZENODO_DEPOSIT_ID=[some zenodo deposit id] BIONOMIA_ZENODO_DEPOSIT_ID=[some other zenodo deposit id]
```

where [some zenodo deposit id] is the location of the Zenodo publication/deposit that contains the generated attributions.tsv.gz derived from the specified BIONOMIA_ZENODO_DEPOSIT_ID . Example of a such attributions.tsv.gz zenodo deposit id id 4777336 can be found at:

Poelen, Jorrit H. (2021). attributions.tsv.gz: a Terse Biodiversity Data Attributions Dataset derived from Bionomia (Version 0.0.2) [Data set]. Zenodo. http://doi.org/10.5281/zenodo.4777336

Note that this publication is enriched with the machine-readable location-agnostic content-based provenance compatible with [Preston](https://preston.guoda.bio) biodiversity dataset tracker. 
