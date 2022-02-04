# EMu Data Prep Script -- to prep Audubon Core dataset including CT data

# [Stuff to update/fix in script:]
# [May need to manually check lines 48 & 68 & fix # of united keyseq columns (if <> 3)]

# STEP 1a: Retrieve dataset in EMu/ecatalogue 
#          (e.g., for Fishes, find all Fishes catalogue records where Publish=OK & HasMM=Y)
# STEP 1b: Report those records using "IPT Audubon Core - with Supp v2" report with these fields:
#
# [1] "Group1_key"                 "ecatalogue_key"              "CATirn"                   
# [4] "DarGlobalUniqueIdentifier"  "AdmGUIDValue_tab"            "MulMimeType"              
# [7] "DetResourceType"            "MulTitle"                    "irn"                      
# [10] "AdmPublishWebNoPassword"   "RIG_SummaryData"             "RigAcknowledgement"       
# [13] "PUB_SummaryData"           "MulDescription"              "DetSubject_tab"           
# [16] "DetResourceDetailsDate0"   "MulMimeFormat"               "ChaMd5Sum"                
# [19] "ChaImageWidth"             "ChaImageHeight"              "AdmDateModified"          
# [22] "MulIdentifier"             "DetResourceSubtype"          "RightsAcknowledgeLocal"   
# [25] "AudAccessURI"              "AudAssociatedObservation"    "AudAssociatedSpecimen"    
# [28] "AudCaptureDevice"          "AudCitation"                 "AudDerivedFrom"           
# [31] "AudFundingAttribution"     "AudIdentifier"               "AudLifeStage"             
# [34] "AudNumbers"                "AudRelatedGeography"         "AudRelatedResourceID"     
# [37] "AudSex"                    "AudSubjectOrientation"       "AudSubjectPart_tab"       
# [40] "AudTaxonCoverage"          "AudTemporalCoverage"         "AudVernacularName"
# "RIGOWN_SummaryData" (RigOwner)  "CRE_SummaryData" (MMcreator) "SecDepartment" (-> IDofContainColl)


# STEP 2: Run this script:

# dept <- readline("Enter the collection you're prepping (e.g. 'bird'): ")
dept <- 'collection'

# IPT resource names are:
#     bird, bird_egg, bryophyte, fishes, fossinverts, fungi, herp, 
#     insect, invertebrate, lichen, mammal, paleobot, pteridophyte
# For Observations:  bird_obs, mammal_obs

# install.packages("tidyr")  # uncomment if not already installed
library("tidyr")


# point to your csv file(s)
CatMMGroup1 <- read.csv(file="data01raw/Group1.csv", stringsAsFactors = F, fileEncoding = "utf8")
MMcreator <- read.csv(file="data01raw/MulMulti.csv", stringsAsFactors = F, fileEncoding = "utf8")
RIGowner <- read.csv(file="data01raw/RigOwner.csv", stringsAsFactors = F, fileEncoding = "utf8")
SecDepar <- read.csv(file="data01raw/SecDepar.csv", stringsAsFactors = F, fileEncoding = "utf8")


# clean linebreaks out of breakable fields:
CatMMGroup1$AudCitation <- gsub("\\n+", "  ", CatMMGroup1$AudCitation)
CatMMGroup1$MulDescription <- gsub("\\n+", " | ", CatMMGroup1$MulDescription)
CatMMGroup1$SupMD5Checksum_tab <- gsub("\\n+", " | ", CatMMGroup1$SupMD5Checksum_tab)

# Concatenate multiple creators into a single field
MMcreator$keyseq <- sequence(rle(as.character(MMcreator$Group1_key))$lengths)
# select only the irn, table-field, & irnseq fields
MM2 <- MMcreator[,2:NCOL(MMcreator)]
MM3 <- spread(MM2, keyseq, CRE_SummaryData, sep="_", convert=T)
# Check next line & fix # of united keyseq columns (if <> 3)
if (ncol(MM3) > 2) {
  MM3cols <- colnames(MM3)[2:ncol(MM3)]
  MM4 <- unite(MM3, "CRE_Summary", all_of(MM3cols), sep=" | ", remove = T)
} else {
  colnames(MM3)[2] <- "CRE_Summary"
  MM4 <- MM3
}
MM4$CRE_Summary <- gsub(" \\| NA", "", MM4$CRE_Summary)


# Concatenate multiple rights-owners into a single field
RIGowner$keyseq <- sequence(rle(as.character(RIGowner$Group1_key))$lengths)
# select only the irn, table-field, & irnseq fields
RIG2 <- RIGowner[,2:NCOL(RIGowner)]
RIG3 <- spread(RIG2, keyseq, RIGOWN_SummaryData, sep="_", convert=T)
# Check next line & fix # of united keyseq columns (if <> 3)
if (NCOL(RIG3) > 2) {
  RIG3cols <- colnames(RIG3)[2:NCOL(RIG3)]
  RIG4 <- unite(RIG3, "RIGOWN_Summary", RIG3cols, sep=" | ", remove = T)
} else {
  colnames(RIG3)[2] <- "RIGOWN_Summary"
  RIG4 <- RIG3
}
RIG4$RIGOWN_Summary <- gsub("\\s+\\|\\s+NA", "", RIG4$RIGOWN_Summary)


# Filter SecDepar to only show Collection Codes
CollDepar <- c("Zoology", "Geology", "Botany", "Anthropology", "Photo Archives", "Action")
SecDepar2 <- unique(SecDepar[which(SecDepar$SecDepartment %in% CollDepar),-1])
SecDepar2$keyseq <- sequence(rle(as.character(SecDepar2$Group1_key))$lengths)
SecDepar3 <- spread(SecDepar2, keyseq, SecDepartment, sep="_", convert=T, fill="")
# Need to manually check next line & fix # of united keyseq columns (if <> 3)
if (ncol(SecDepar3) > 2) {
  SecCols <- colnames(SecDepar3)[2:ncol(SecDepar3)]
  SecDepar4 <- unite(SecDepar3, "SecDepartment", all_of(SecCols), sep=" | ", remove = T)
  # SecDepar4 <- unite(SecDepar3, SecDepartment, keyseq_1:keyseq_3, sep=" | ", remove = T)
} else {
  colnames(SecDepar3)[2] <- "SecDepartment"
  SecDepar4 <- SecDepar3
}

SecDepar4$SecDepartment <- gsub("(\\s+\\|\\s+)+", " | ", SecDepar4$SecDepartment)
SecDepar4$SecDepartment <- gsub("^\\s+|(^\\s+\\|\\s+)|\\s+\\|\\s+$|\\s+$", "", SecDepar4$SecDepartment)


# Overwrite main(preview)-jpg-md5sum with supp-ct-MD5sum
if (NROW(CatMMGroup1[which(CatMMGroup1$DetResourceSubtype == "CT Data"),]) > 0) {
  CatMMGroup1$ChaMd5Sum[CatMMGroup1$DetResourceSubtype == "CT Data"] <- CatMMGroup1$SupMD5Checksum_tab[CatMMGroup1$DetResourceSubtype == "CT Data"]
}
CatMMGroup1 <- dplyr::select(CatMMGroup1, -SupMD5Checksum_tab)

# Merge all data-frames
IPTout <- merge(CatMMGroup1, MM4, by="Group1_key", all.x=T)
IPTout <- merge(IPTout, RIG3, by="Group1_key", all.x=T)
IPTout <- merge(IPTout, SecDepar4, by="Group1_key", all.x=T)

IPTout <- unique(IPTout)

# Pipe-delimit identifiers
IPTout$AudIdentifier <- gsub("\\n+", " | ", IPTout$AudIdentifier)
IPTout$AudIdentifier <- gsub("\\s+\\|\\s+", " | ", IPTout$AudIdentifier)
# IPTout$AudIdentifier <- gsub("ark:/", "https://n2t.net/ark:/", IPTout$AudIdentifier)

# Overwrite main(preview)-jpg-metadata with supp-ct-metadata [blank for now]
if (NROW(IPTout[which(IPTout$DetResourceSubtype == "CT Data"),]) > 0) {
  IPTout$ChaImageHeight[IPTout$DetResourceSubtype == "CT Data"] <- ""
  IPTout$ChaImageWidth[IPTout$DetResourceSubtype == "CT Data"] <- ""
  IPTout$MulMimeFormat[IPTout$DetResourceSubtype == "CT Data"] <- ""
}

# add URLs
IPTout$accessURI <- IPTout$AudAccessURI


IPTout$accessURI[IPTout$DetResourceType == "URL"] <- IPTout$MulIdentifier[IPTout$DetResourceType == "URL"]


# add ac:variant
IPTout$variantLiteral <- "" 
IPTout$variantLiteral[is.na(IPTout$AudIdentifier)==F] <- "mediumQualityFurtherInformationURL"

# add ac:Service Access Point
IPTout$hasServiceAccessPoint <- ""
IPTout$hasServiceAccessPoint[is.na(IPTout$AudIdentifier)==F] <- paste0("https://mm.fieldmuseum.org/",
                                                                       IPTout$AudIdentifier[is.na(IPTout$AudIdentifier)==F])


# add separate rows for separate CT hasServiceAccessPoints
# # [at least until GBIF can render multiple service access points]
if (NROW(IPTout[IPTout$DetResourceSubtype=="CT Data",]) > 0) {
  
  CTrows <- IPTout[IPTout$DetResourceSubtype=="CT Data",]
  CTrows$variantLiteral <- "goodQualityFurtherInformationURL"
  CTrows$hasServiceAccessPoint <- paste0("https://n2t.net/",
                                         gsub(".*\\|\\s+", "", CTrows$AdmGUIDValue_tab))
  
  IPTout <- rbind(IPTout, CTrows)

}

# strip line-breaks 
# may also need to gsub("\n", " \\| ", [all COLs, or at least table->text cols])
IPTout$AudSubjectPart_tab[which(grepl("\n", IPTout$AudSubjectPart_tab)==TRUE)] <- gsub("\n", " | ", IPTout$AudSubjectPart_tab[which(grepl("\n", IPTout$AudSubjectPart_tab)==TRUE)])
IPTout$DetSubject_tab[which(grepl("\n", IPTout$DetSubject_tab)==TRUE)] <- gsub("\n", " | ", IPTout$DetSubject_tab[which(grepl("\n", IPTout$DetSubject_tab)==TRUE)])
IPTout$MulDescription[which(grepl("\n", IPTout$MulDescription)==TRUE)] <- gsub("\n", " | ", IPTout$MulDescription[which(grepl("\n", IPTout$MulDescription)==TRUE)])
IPTout$DetResourceDetailsDate0[which(grepl("\n", IPTout$DetResourceDetailsDate0)==TRUE)] <- gsub("\n", " | ", IPTout$DetResourceDetailsDate0[which(grepl("\n", IPTout$DetResourceDetailsDate0)==TRUE)])
IPTout$RightsAcknowledgeLocal[which(grepl("\n", IPTout$RightsAcknowledgeLocal)==TRUE)] <- gsub("\n", "  ", IPTout$RightsAcknowledgeLocal[which(grepl("\n", IPTout$RightsAcknowledgeLocal)==TRUE)])

# also strip quotes
IPTout$AudRelatedGeography[which(grepl('"', IPTout$AudRelatedGeography)==TRUE)] <- gsub('"', "", IPTout$AudRelatedGeography[which(grepl('"', IPTout$AudRelatedGeography)==TRUE)])
IPTout$MulDescription[which(grepl('"', IPTout$MulDescription)==TRUE)] <- gsub('"', "", IPTout$MulDescription[which(grepl('"', IPTout$MulDescription)==TRUE)])
IPTout$MulTitle[which(grepl('"', IPTout$MulTitle)==TRUE)] <- gsub('"', "", IPTout$MulTitle[which(grepl('"', IPTout$MulTitle)==TRUE)])
IPTout$RightsAcknowledgeLocal[which(grepl('"', IPTout$RightsAcknowledgeLocal)==TRUE)] <- gsub('"', "", IPTout$RightsAcknowledgeLocal[which(grepl('"', IPTout$RightsAcknowledgeLocal)==TRUE)])

# not currently used/mapped, but fixed in case
IPTout$RigAcknowledgement[which(grepl("\n", IPTout$RigAcknowledgement)==TRUE)] <- gsub("\n", "  ", IPTout$RigAcknowledgement[which(grepl("\n", IPTout$RigAcknowledgement)==TRUE)])
IPTout$RigAcknowledgement[which(grepl('"', IPTout$RigAcknowledgement)==TRUE)] <- gsub('"', "", IPTout$RigAcknowledgement[which(grepl('"', IPTout$RigAcknowledgement)==TRUE)])

# Excluding GUID-check to allow multiple GUIDs in ac:identifier
# # FILTER for badly-formed GUIDs 
# GUIDcheck <- IPTout[which(nchar(IPTout$AudIdentifier)!=36),]
# IPTout2 <- IPTout[which(!IPTout$irn %in% GUIDcheck$irn),]

# DROP AdmPublishWebNoPassword=="No" records?
IPTout2 <- IPTout[which(tolower(IPTout$AdmPublishWebNoPassword)=="yes"),]
IPTout2 <- IPTout2[,-c(1,2,3)]
IPTout2$metadataLanguageLiteral <- "eng"


# Rights & Credit
IPTout2$WebStatement <- "https://www.fieldmuseum.org/field-museum-natural-history-conditions-and-suggested-norms-use-collections"
IPTout2$AudCitation[which(is.na(IPTout2$AudCitation)==TRUE)] <- "https://www.fieldmuseum.org/preferred-citations-collections-data-and-images"


# Add IDofContainingCollection

SecDepartment <- c("Action",
                   "Amphibians and Reptiles",
                   "Birds",
                   "Botany",
                   "Fishes",
                   "Insects",
                   "Invertebrate Zoology",
                   "Mammals")

IDofContainingCollection <- c("http://biocol.org/urn:lsid:biocol.org:col:34795",
                              "http://grbio.org/cool/05pf-h6mh",
                              "http://grbio.org/cool/91hw-75rx",
                              "http://grbio.org/cool/90as-ki3a",
                              "http://grbio.org/cool/zdsi-36ka",
                              "http://grbio.org/cool/n9zv-z18s",
                              "http://grbio.org/cool/csae-ip0v",
                              "http://grbio.org/cool/wvvh-z4v9") 

CollID <- data.frame(SecDepartment, IDofContainingCollection)

IPTout3 <- merge(IPTout2, CollID, by="SecDepartment", all.x=T)
IPTout3$IDofContainingCollection <- as.character(IPTout3$IDofContainingCollection)
IPTout3$IDofContainingCollection[which(is.na(IPTout3$IDofContainingCollection)==T)] <- "http://biocol.org/urn:lsid:biocol.org:col:34795"


IPTout3$hashFunction <- "MD5"

IPTout3 <- IPTout3[,c(2:NCOL(IPTout3),1)]


# NOTE: Remember to relabel your columns
ColLabels <- colnames(IPTout3)
ColLabels <- gsub("^DarGlobalUniqueIdentifier$", "occurrenceID", ColLabels)
ColLabels <- gsub("^AudIdentifier$", "dcterms.identifier", ColLabels)
ColLabels <- gsub("^DetResourceSubtype$", "subtypeLiteral", ColLabels)
ColLabels <- gsub("^DetResourceType$", "dc.type", ColLabels)
ColLabels <- gsub("^MulTitle$", "dcterms.title", ColLabels)
ColLabels <- gsub("^irn$", "providerManagedID", ColLabels)
ColLabels <- gsub("^RIG_SummaryData$", "dc.rights", ColLabels)
ColLabels <- gsub("^RIGOWN_Summary$", "Owner", ColLabels)
ColLabels <- gsub("^CRE_Summary$", "dc.creator", ColLabels)
ColLabels <- gsub("^PUB_SummaryData$", "providerLiteral", ColLabels)
ColLabels <- gsub("^MulDescription$", "dcterms.description", ColLabels)
ColLabels <- gsub("^DetSubject_tab$", "tag", ColLabels)
ColLabels <- gsub("^DetResourceDetailsDate0$", "CreateDate", ColLabels)
ColLabels <- gsub("^MulMimeFormat$", "dc.format", ColLabels)
ColLabels <- gsub("^ChaMd5Sum$", "hashValue", ColLabels)
ColLabels <- gsub("^ChaImageWidth$", "PixelXDimension", ColLabels)
ColLabels <- gsub("^ChaImageHeight$", "PixelYDimension", ColLabels)
ColLabels <- gsub("^AdmDateModified$", "MetadataDate", ColLabels)
ColLabels <- gsub("^AudCitation$", "Credit", ColLabels)

ColLabels2 <- gsub("\\.", ":", ColLabels)
# ColLabels2 <- gsub("^Aud", "", ColLabels2)  # duplicates some columns currently


# Setup output directory & csv
if (!dir.exists("data02output")) {
  dir.create("data02output")
}

# EXPORT
IPTout3 <- as.data.frame(rbind(ColLabels2,IPTout3))
IPTout4 <- unique(IPTout3)
write.table(IPTout4, 
            file=paste0("data02output/field_media_", dept,".csv"),
            row.names = F, sep=",", na="", col.names = F, quote = TRUE)

if(exists("GUIDcheck")) {
  
  print(paste0("GUID errors -- see 'guid_check_", dept, ".csv'"))
  
  write.table(GUIDcheck,
              file = paste0("data02output/guid_check_", dept, ".csv"),
              row.names = F, sep=",", na="", col.names = T, quote = TRUE)  
  
} else {

  print("GUIDs all OK")
    
}


print(Sys.time())

print("REMINDER - Check output in notepad -- does # rows there match rows in IPTout4? ")
print(paste("Number of rows in IPTout4 (includes header-row) =", NROW(IPTout4)))
