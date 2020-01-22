# Prep Related Resource extension datasets

# 1. Retrieve Catalog records with related resources
# 2. Report with "IPT Related Resource"
#      Generated CSVs include:
#         - ecatalog.csv
#         - Eco.csv
#         - Rel.csv
# 3. Save report to [this repo]/data01raw/relationships

library(readr)
library(tidyr)

relat_raw <- read_csv("data01raw/relationships/Group1.csv")

# Group.DarGlobalUniqueID                     = resourceID  (= occurrenceID)
# Group.relatedResourceID                     = relatedResourceID
# Group.RelRelationship_tab                   = relationshipOfResource
# Group.DarScientificName/[to be parsed]"     = scientificName
# Group.RelNotes                              = relationshipRemarks
# "[to be parsed]"                            = relationshipAccordingTo
# "[to be parsed]"                            = relationshipEstablishedDate


relat <- data.frame("resourceID" = relat_raw$DarGlobalUniqueIdentifier,
                    "relatedResourceID" = relat_raw$relatedResourceID,
                    "relationshipOfResource" = relat_raw$RelRelationship,
                    "scientificName" = relat_raw$DarScientificName, 
                    "RelNotes" = relat_raw$RelNotes,
                    stringsAsFactors = FALSE)


#  Parse RelNotes
#
#   RelNotes values from EMu need to be formatted like this:
#    “Count: [value] | ObjectURI: [OBJECT GUID or URI if not FMNH catalogue record] | RecordedByIRN: [Recorder-1 irn, Recorder-2 irn] | RecordedBySummary: [Recorder-1 name, Recorder-2 name] | TaxonIRN: [irn] | TaxonSummary: [Summary] | Notes: [Text from notes]”

relat$Count <- gsub("Count:\\s*|\\s*\\|\\s*ObjURI:.*", "", relat$RelNotes)
relat$relatedResourceID_2 <- gsub(".*ObjURI:\\s*|\\s*\\|\\s*RecordedByIRN.*", "", relat$RelNotes)
relat$RecordedByIRN <- gsub(".*RecordedByIRN:\\s*|\\s*\\|\\s*RecordedBySummary.*", "", relat$RelNotes)
relat$relationshipAccordingTo <- gsub(".*RecordedBySummary:\\s*|\\s*\\|\\s*TaxonIRN.*", "", relat$RelNotes)
relat$TaxonIRN <- gsub(".*TaxonIRN:\\s*|\\s*\\|\\s*TaxonSummary.*", "", relat$RelNotes)
relat$scientificName_2 <- gsub(".*TaxonSummary:\\s*|\\s*\\|\\s*Notes.*", "", relat$RelNotes)
relat$relationshipRemarks <- gsub(".*\\|\\s*Notes:\\s*", "", relat$RelNotes)


# # Separate seems simpler but more fragile if RelNotes value doesn't strictly follow format
# relat <- separate(relat, col = "relationshipRemarks",
#                   into = c("Count", "relatedResourceID_2", 
#                            "RecordedByIRN", "relationshipAccordingTo",
#                            "TaxonIRN", "scientificName_2", "relationshipRemarks"),
#                   sep = "\\|", remove = TRUE, convert = FALSE,
#                   extra = "warn", fill = "warn")
#
# # Cleanup parsed values
# relat$Count <- gsub("Count:\\s*", "", relat$Count)
# relat$relatedResourceID_2 <- gsub("ObjURI:\\s*", "", relat$relatedResourceID_2)
# relat$relationshipAccordingTo <- gsub("RecordedBy:\\s*", "", relat$relationshipAccordingTo)
# relat$TaxonIRN <- gsub("TaxonIRN:\\s*", "", relat$TaxonIRN)
# relat$scientificName_2 <- gsub("TaxonSummary:\\s*", "", relat$scientificName_2)
# relat$relationshipRemarks <- gsub("Notes:\\s*", "", relat$relationshipRemarks)


relat <- as.data.frame(sapply(relat, trimws, simplify = FALSE),
                       stringsAsFactors = F)



relat <- as.data.frame(sapply(relat, gsub, pattern = "NULL", replacement = "",
                              simplify = FALSE),
                       stringsAsFactors = FALSE)


# Merge fields mapped to multiple pre-dev fields
relat$relatedResourceID[is.na(relat$relatedResourceID)==T] <- relat$relatedResourceID_2[is.na(relat$relatedResourceID)==T]
relat$scientificName[is.na(relat$scientificName)==T] <- relat$scientificName_2[is.na(relat$scientificName)==T]


# Add placeholders for missing fields
relat$resourceRelationshipID <- ""
relat$relationshipEstablishedDate <- ""


# Prep final export table
relat_out <- relat[,c("resourceRelationshipID", "resourceID", "relatedResourceID",
                      "relationshipOfResource", "relationshipAccordingTo",
                      "relationshipEstablishedDate", "relationshipRemarks",
                      "scientificName")]


# output resource relationship extension

if(!dir.exists("data02output/relation")) {
  dir.create("data02output/relation")  
}

write.csv(relat_out, 
          file = paste0("data02output/relation/relation_",
                        gsub("-|\\s+|:", "", Sys.time()),
                        ".csv"),
          row.names = FALSE,
          quote = TRUE,
          na = "")


