# Reformat EMu csv's 'DarDateModified' for IPT dwc:modified

# 1 - run the appropriate specimen "IPT" report
# (IPT_Insects_CE?)


library("readr")

# Import EMu CSV report
cat <- read_csv(file = "data01raw/IPT_DwC/ecatalog.csv",
                guess_max = 475000)

# # NOTE - make sure file encoding is properly importedL
# # IF grepl("Ã", cat[1:NCOL(cat)]) > 0 ), REIMPORT

# test <- data.frame("origmod" = cat$DarDateLastModified,
#                    "modmod" = "",
#                    stringsAsFactors = FALSE)

cat$DarDateLastModified <- gsub("(^\\d{4}\\-)(\\d{1}\\-)",
                                "\\10\\2", 
                                cat$DarDateLastModified)

cat$DarDateLastModified <- gsub("(^\\d+\\-\\d+\\-)(\\dT)",
                                "\\10\\2", 
                                cat$DarDateLastModified)

cat$DarDateLastModified <- gsub("CMT$",
                                "-0600", 
                                cat$DarDateLastModified)

# # If need to strip seconds & milliseconds, uncomment next line & rerun:
# cat$DarDateLastModified <- gsub("(T\\d+\\:\\d+)(\\:\\d{2}\\.\\d+)",
#                                 "\\1",
#                                 cat$DarDateLastModified)

write.csv(cat, 
          "data02output/ecatalog_dateMod_processed.csv",
          na = "",
          row.names = FALSE,
          fileEncoding = "UTF-8",
          quote = 1:NCOL(cat))
