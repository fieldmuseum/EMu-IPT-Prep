# Clean CSVs for DwC

# 1 - run the appropriate specimen "IPT" report
# 2 - add the output 'ecatalog.csv' to the data01raw/iptSpec/ directory
# 3 - run this script

library("readr")

if(!dir.exists("data01raw/iptSpec")) {
  
  if(!dir.exists("data01output")) {
    
    dir.create("data01output")
    
  }
  
  dir.create("data01output")
  print("Dear Human: I created a 'data01output/iptSpec' directory")
  print("-- Please add 'ecatalog.csv' to the 'iptSpec' directory")
  
}

# Import CSVs
cat <- read_csv("data01raw/iptSpec/ecatalog.csv",
                guess_max = 1000000)

# # NOTE - make sure file encoding is properly imported
# # IF grepl("Ã", cat[1:NCOL(cat)]) > 0 ), REIMPORT

if (!'DarDateLasteModified' %in% colnames(cat)) {
  
  if ('modified' %in% colnames(cat)) {
    cat$DarDateLastModified <- cat$modified
  }
}

if ('DarDateLasteModified' %in% colnames(cat)) {
  # if (NROW(cat$DarDateLastModified) > 0) {
 
  print('Converting dates...')
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

} else {
  
  print("Warning - Input CSV missing 'DarDateLastModified' or 'modified' column")
  
}

# Function to check & replace carriage returns
piper <- function (x) {
  x[1:NCOL(x)] <- sapply(x[1:NCOL(x)],
                         function (y) gsub("\\n|\\r", "|", y))
  return(x)
}


# Check/Replace carriage returns
cat2 <- piper(cat)

if(!dir.exists("data02output")) {
  
  dir.create("data02output")
  print("created 'output' directory")
  
}

csv_path <- "data02output/"
                         
# Write out results
write_csv(cat2, 
          na = "",
          file = paste0(csv_path,"Catalog2.csv"))
