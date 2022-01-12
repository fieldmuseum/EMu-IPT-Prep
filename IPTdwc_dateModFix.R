# Reformat EMu csv's 'DarDateModified' for IPT dwc:modified

# Step 1 - In EMu, run the appropriate specimen "IPT" report (e.g. "IPT_Insects_CE")
# Step 2 - Put the output ecatalog.csv in this repo's data01raw/IPT_DwC/ dir
# Step 3 - Run the script below:

library("readr")

# Import EMu CSV report
cat <- read_csv(file = "data01raw/IPT_DwC/ecatalog.csv",
                guess_max = 475000)


# Add leading zero for month
cat$DarDateLastModified <- gsub("(^\\d{4}\\-)(\\d{1}\\-)",
                                "\\10\\2", 
                                cat$DarDateLastModified)

# Add leading zero for day
cat$DarDateLastModified <- gsub("(^\\d+\\-\\d+\\-)(\\dT)",
                                "\\10\\2", 
                                cat$DarDateLastModified)

# Change suffix from timezone to UTF-relative
cat$DarDateLastModified <- gsub("CMT$",
                                "-0600", 
                                cat$DarDateLastModified)

# # If need to strip seconds & milliseconds, uncomment next line & rerun:
# cat$DarDateLastModified <- gsub("(T\\d+\\:\\d+)(\\:\\d{2}\\.\\d+)",
#                                 "\\1",
#                                 cat$DarDateLastModified)

# Setup output directory & csv
if (!dir.exists("data02output")) {
  dir.create("data02output")
}

write.csv(cat, 
          "data02output/ecatalog_dateMod_processed.csv",
          na = "",
          row.names = FALSE,
          fileEncoding = "UTF-8",
          quote = 1:NCOL(cat))
