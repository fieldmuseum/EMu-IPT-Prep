# Script to prep DwC datasets processed via Crystal Rpts

library('readr')

# ext <- read_csv("C:/Users/kwebbink/Desktop/field_rr_insect/field_rr_insect.csv",
#                guess_max = 100000)
# core <- read_csv("C:/Users/kwebbink/Desktop/field_rr_insect/field_ipt_insect.zip",
#                 guess_max = 1000000)
#
# ext_no_ipt <- ext[which(!ext$resourceID %in% core$DarGlobalUniqueIdentifier...36),]
# 
# ext_yes_ipt <- ext[which(ext$resourceID %in% core$DarGlobalUniqueIdentifier...36),]


# Strip linebreaks

# # Function to check & replace linebreaks
piper <- function (x) {
  x[1:NCOL(x)] <- sapply(x[1:NCOL(x)],
                         function (y) gsub("\\n|\\r", "|", y))
  return(x)
}


# Check that all occIDs in extension are in core dataset
ext <- read_csv("data02output/field_media_mammal_obs.zip",
                guess_max = 100000)

input_file <- "data02output/field_ipt_mammal_obs_raw.zip"

input_encoding <- guess_encoding(input_file, n_max = 1000000)

core <- read_csv(input_file,
                guess_max = 1000000,
                locale = readr::locale(encoding = input_encoding$encoding[1]))


ext_no_ipt <- ext[which(!ext$occurrenceID %in% core$occurrenceID),]

ext_yes_ipt <- ext[which(ext$occurrenceID %in% core$occurrenceID),]

if (NROW(core) == NROW(unique(core$occurrenceID))) {
  
  print(paste("No duplicate occurrenceIDs found in",
              NROW(core), "rows -- Ready for core"))
  
} else {
  
  occID_check <- dplyr::count(core, occurrenceID)
  occID_dups <- occID_check[occID_check$n > 1,]
  
  print("WARNING: duplicate occurrenceIDs found:")
  print(occID_dups)
  print("See `occID_dups` dataframe for list")
  
}


# Clean core dataset
core_2 <- piper(core)


# Exports

# Output only the Extension records with id's in Core dataset 
write.csv(ext_yes_ipt, 
          file = paste0("data02output/ext_check_ids.csv"),
          row.names = FALSE,
          quote = TRUE,
          na = "")

# Output cleaned DwC dataset
write.csv(core_2, 
          file = "data02output/field_ipt_mammal_obs.csv",
          row.names = FALSE,
          quote = TRUE,
          na = "")

# # # #
# 
# mm_dates <- read_csv("C:/Users/kwebbink/Desktop/mm_date_created/Group1.csv")
# 
# mm_dates$file <- paste0(mm_dates$AudIdentifier,
#                         gsub("(.+)(\\.+)","\\2",mm_dates$MulIdentifier))
# mm_dates_2 <- mm_dates[which(mm_dates$DetResourceDetailsDescription=="Created"),]
# 
# mm_dates_out <- mm_dates[,c("AudIdentifier",)]