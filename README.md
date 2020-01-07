# EMu-IPT-Prep
Tools to prep EMu data for IPT

These scripts are part of the FMNH workflow for publishing specimen data from EMu to the [Field Museum IPT](https://fmipt.fieldmuseum.org).

## - IPTac.R
  - prepares EMu Catalogue and Multimedia data as an [Audubon Core](https://github.com/tdwg/ac/blob/master/docs/termlist.md) extension for multimedia associated with occurrences.
  - IPTac_v1.R is an older version (pre-CT scan data) for preparing Multimedia with a simpler record structure

## - IPTcd.R
  - prepares a [draft] [Collections Description](https://github.com/tdwg/cd) dataset for inventories, accessions, or other data not yet resolved to 'occurrence-level' specificity.

## - IPTdwc.R
  - includes checks to help prepare EMu Catalogue data as a [Darwin Core](https://github.com/tdwg/dwc/blob/master/docs/terms/index.md) dataset.

## - IPTrelationPreDev.R
  - prepares EMu Catalogue data (pre-EMu-development) as a [Resource Relationship](https://tools.gbif.org/dwca-validator/extension.do?id=dwc:ResourceRelationship) extension for occurrences with interactions.
