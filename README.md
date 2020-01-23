# EMu-IPT-Prep
Tools to prep EMu data for IPT

These scripts are part of the FMNH workflow for publishing specimen data from EMu to the [Field Museum IPT](https://fmipt.fieldmuseum.org).
Information on how to structure data/reports from EMu is at the top of each script.

## IPTac.R
  - prepares EMu Catalogue and Multimedia data as an [Audubon Core](https://github.com/tdwg/ac/blob/master/docs/termlist.md) extension for multimedia associated with occurrences.
  - IPTac_v1.R is an older version (pre-CT scan data) for preparing Multimedia with a simpler record structure

## IPTcd.R
  - prepares a [draft] [Collections Description](https://github.com/tdwg/cd) dataset for inventories, accessions, or other data not yet resolved to 'occurrence-level' specificity.

## IPTdwc.R
  - includes checks to help prepare EMu Catalogue data as a [Darwin Core](https://github.com/tdwg/dwc/blob/master/docs/terms/index.md) dataset.

## IPTrr_PreDev.R
  - prepares EMu Catalogue data (pre-EMu-development) as a [Resource Relationship](https://tools.gbif.org/dwca-validator/extension.do?id=dwc:ResourceRelationship) extension for occurrences with interactions.
    - Input data should include these fields (grouped into 1 csv titled 'Group1.csv':
      - DarGlobalUniqueID
      - RelRelationship_tab
      - RelObjectsRef_tab.DarGlobalUniqueIdentifier (relabeled "relatedResourceID" in EMu report)
      - RelObjectsRef_tab.DarScientificName
      - RelNotes       

    - Data in **ecatalogue.RelNotes** should be in the temporary format shown here:
      ```
      Count: [#] | ObjURI: [OBJECT GUID or URI] | RecordedByIRN: [Recorder-1 irn], [Recorder-2 irn], [...] | RecordedBySummary: [Recorder-1 name], [Recorder-2 name], ... | TaxonIRN: [Taxon irn] | TaxonSummary: [Taxon name] | Notes: [Text from notes]
      ```
      e.g.:
      ```
      Count: NULL | ObjURI: 3cf7cd-4658-9c7a-399604db1-7b3f979c1 | RecordedByIRN: 326545, 324589 | RecordedBySummary: J.B. Smith, E.B. White | TaxonIRN: 691087 | TaxonSummary: Thunnus | Notes: Taken from the stomachs of 3 Tuna fish, about 25 lb. each.
      ```

    - Fields/Parsed pieces can then be mapped to corresponding Resource Relationship fields as shown here:
      - DarGlobalUniqueID                = resourceID  (= occurrenceID)
      - relatedResourceID                = relatedResourceID
      - RelRelationship_tab              = relationshipOfResource
      - DarScientificName                = scientificName
      - RelNotes "ObjURI:"               = relationshipRemarks (if RelObjectsRef_tab.DarGlobalUniqueIdentifier = Null)
      - RelNotes "RecordedBySummary:"    = relationshipAccordingTo
      - RelNotes "TaxonSummary:"         = scientificName (if RelObjectsRef_tab.DarScientificName = Null)
      - RelNotes "Notes:"                = relationshipRemarks

    - Parsed pieces that are not mapped here are useful for EMu post-development data cleanup (e.g., Count and TaxonIRN)

    
