# Prep Related Resource extension datasets
# Created 2021-May-4 (post-dev)

# 1. Retrieve Catalog records with related resources
#       - i.e. where RelNhID is NOT NULL
# 2. Report with "IPT Related Resource 2021"
#      Generated CSVs include:
#         - ecatalog.csv
#         - Group1.csv
#
# 3. Save report to [this repo]/data01raw/relationships

library(readr)
library(tidyr)

relat_raw <- read_csv("data01raw/relationships/Group1.csv",
                      col_types = cols(.default = col_character()))

relat_raw <- type_convert(relat_raw)

# # test with sample data
# relat_raw <- read_csv("sampleData/relationships/Group1.csv")

relat <- data.frame("resourceID" = relat_raw$DarGlobalUniqueIdentifier,
                    "relatedResourceID" = relat_raw$RelNhURI,
                    "relatedResourceID_2" = relat_raw$RelNhObj_DarGlobalUniqueIdentifier,
                    "relationshipOfResource" = relat_raw$RelNhRelationship,
                    "scientificName" = relat_raw$RelNhTax_SummaryData, # check/replace 
                    "relationshipRemarks" = relat_raw$RelNhRemarks,
                    "resourceRelationshipID" = relat_raw$RelNhID,
                    "Count" = relat_raw$RelNhCount,
                    "relationshipAccordingTo" = relat_raw$RelNhAccordingToRef_SummaryData,
                    "relationshipEstablishedDate" = relat_raw$RelNhDate,
                    "RelNhRepo_SummaryData" = relat_raw$RelNhRepo_SummaryData,
                    "RelNotes" = relat_raw$RelNotes,
                    stringsAsFactors = FALSE)


# #  Parse RelNotes
# #
# #   RelNotes values from EMu need to be formatted like this:
# #    “Count: [value] | ObjectURI: [OBJECT GUID or URI if not FMNH catalogue record] | RecordedByIRN: [Recorder-1 irn, Recorder-2 irn] | RecordedBySummary: [Recorder-1 name, Recorder-2 name] | TaxonIRN: [irn] | TaxonSummary: [Summary] | Notes: [Text from notes]”
# 
# # relat$Count <- gsub("Count:\\s*|\\s*\\|\\s*ObjURI:.*", "", relat$RelNotes)
relat$relatedResourceID_3 <- gsub(".*ObjURI:\\s*|\\s*\\|\\s*RecordedByIRN.*", "", relat$RelNotes)
# # relat$RecordedByIRN <- gsub(".*RecordedByIRN:\\s*|\\s*\\|\\s*RecordedBySummary.*", "", relat$RelNotes)
# # relat$relationshipAccordingTo <- gsub(".*RecordedBySummary:\\s*|\\s*\\|\\s*TaxonIRN.*", "", relat$RelNotes)
# # relat$TaxonIRN <- gsub(".*TaxonIRN:\\s*|\\s*\\|\\s*TaxonSummary.*", "", relat$RelNotes)
relat$scientificName_2 <- gsub(".*TaxonSummary:\\s*|\\s*\\|\\s*Notes.*", "", relat$RelNotes)
# relat$relationshipRemarks <- gsub(".*\\|\\s*Notes:\\s*", "", relat$RelNotes)


relat <- as.data.frame(sapply(relat, trimws, simplify = FALSE),
                       stringsAsFactors = F)


relat <- as.data.frame(sapply(relat, gsub, pattern = "NULL", replacement = "",
                              simplify = FALSE),
                       stringsAsFactors = FALSE)


# Merge fields mapped to multiple pre-dev fields
relat$relatedResourceID_2[is.na(relat$relatedResourceID_2)==T] <- relat$relatedResourceID_3[is.na(relat$relatedResourceID_2)==T]
relat$relatedResourceID[is.na(relat$relatedResourceID)==T] <- relat$relatedResourceID_2[is.na(relat$relatedResourceID)==T]
relat$scientificName[is.na(relat$scientificName)==T] <- relat$scientificName_2[is.na(relat$scientificName)==T]


# Add related Repo to relationshipRemarks
relat$relationshipRemarks[is.na(relat$RelNhRepo_SummaryData)==F] <- paste0(relat$relationshipRemarks[is.na(relat$RelNhRepo_SummaryData)==F],
                                                                           " | relatedResourceID Repo: ",
                                                                           relat$RelNhRepo_SummaryData[is.na(relat$RelNhRepo_SummaryData)==F])


# Add scientificName to relationshipRemarks until IPT can map sciName
relat$relationshipRemarks[is.na(relat$scientificName)==F] <- paste0(relat$relationshipRemarks[is.na(relat$scientificName)==F],
                                                                    " | scientificName: ",
                                                                    relat$scientificName[is.na(relat$scientificName)==F])

# cleanup NA values
relat[is.na(relat)] <- ""
# Clean relationshipRemarks
relat$relationshipRemarks <- gsub('^NA\\s+\\|\\s+|"', "", relat$relationshipRemarks)
relat$relationshipRemarks <- gsub("PrepType:\\s*\\|\\s*", "", relat$relationshipRemarks)
relat$relationshipRemarks <- gsub("(\\s*\\r\\s*|\\s*\\n\\s*)+", " ; ", relat$relationshipRemarks)



# Prep final export table
relat_out <- relat[,c("resourceRelationshipID", "resourceID", "relatedResourceID",
                      "relationshipOfResource", "relationshipAccordingTo",
                      "relationshipEstablishedDate", "relationshipRemarks",
                      "scientificName", "Count")]


# output resource relationship extension


if(!dir.exists("data02output/relation")) {
  
  if(!dir.exists("data02output")) {
    
    dir.create("data02output")
    print("created 'output' directory")
    
  }
  
  dir.create("data02output/relation") 
  print("created 'relation' output subdirectory")
  
}


write.csv(relat_out, 
          file = paste0("data02output/relation/relation_",
                        gsub("-|\\s+|:", "", Sys.time()),
                        ".csv"),
          row.names = FALSE,
          quote = TRUE,
          na = "")

