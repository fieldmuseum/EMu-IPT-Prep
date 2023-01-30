# Clean CSVs for DwC

# 1 - run the appropriate specimen "IPT" report from EMu
# 2 - add the output 'ecatalog.csv' to this repo's data01raw/iptSpec/ directory
# 3 - run this IPTdwc.R script

library("readr")

if(!dir.exists("data01raw/iptSpec")) {
  
  dir.create("data01raw/iptSpec", recursive = T)
  print("A 'data01raw/iptSpec' directory was newly created")
  print("-- Please add your 'ecatalog.csv' to the 'iptSpec' directory")
  
}

#### Import CSVs ####
cat <- read_csv("data01raw/iptSpec/ecatalog.csv",
                guess_max = 1000000)

# # NOTE - make sure file encoding is properly imported
# # IF grepl("Ã", cat[1:NCOL(cat)]) > 0 ), REIMPORT


#### Setup Cleanup Functions: ####

# # Function to check & fix YYYY-MM-DD date fields to ISO date-format
date_fixer <- function (df_to_fix=cat,
                        column_to_fix="modified",
                        backup_column="DarDateLastModified") {
  
  if (nchar(backup_column) > 0) {
    if (!column_to_fix %in% colnames(df_to_fix)) {
      
      if (backup_column %in% colnames(df_to_fix)) {
        df_to_fix[[column_to_fix]] <- df_to_fix[[backup_column]]
      }
      
      else {
        
        print(paste("Warning - Input dataframe",
                    df_to_fix, "missing 'column_to_fix'",
                    column_to_fix, "or 'backup_column'", 
                    backup_column))
        
      }
    }
  }
  
  if (column_to_fix %in% colnames(df_to_fix)) {
    # if (NROW(cat$DarDateLastModified) > 0) {
    
    print('Converting dates...')
    # Add leading zero for month
    df_to_fix[[column_to_fix]] <- gsub("(^\\d{4}\\-)(\\d{1}\\-)",
                         "\\10\\2", 
                         df_to_fix[[column_to_fix]])
    
    # Add leading zero for day
    df_to_fix[[column_to_fix]] <- gsub("(^\\d+\\-\\d+\\-)(\\dT)",
                         "\\10\\2", 
                         df_to_fix[[column_to_fix]])
    
    # Change suffix from timezone to UTF-relative
    df_to_fix[[column_to_fix]] <- gsub("CMT$",
                         "-0600", 
                         df_to_fix[[column_to_fix]])
    
    # If need to strip seconds & milliseconds, uncomment next line & rerun:
    df_to_fix[[column_to_fix]] <- gsub("(T\\d+\\:\\d+)(\\:\\d{1,2}\\.\\d+)",
                         "\\1",
                         df_to_fix[[column_to_fix]])
    
    return(df_to_fix[[column_to_fix]])
    
  } else {
    
    print(paste("Warning - Input dataframe",
                df_to_fix, "missing 'column_to_fix'",
                column_to_fix, "or 'backup_column'", 
                backup_column))
    
  }
  
}

# Function to check & replace carriage returns
piper <- function (x) {
  x[1:NCOL(x)] <- sapply(x[1:NCOL(x)],
                         function (y) gsub("\\n|\\r", "|", y))
  return(x)
}


#### Prep & Cleanup Data-fields ####


# Prep ColDateVisitedFrom if it's missing

if (!'ColDateVisitedFrom' %in%  colnames(cat)) {
  
  if (grepl("year|month|day", colnames(cat)) > 0) {
    cat$ColDateVisitedFrom <- paste0(cat$year,
                                     "-", cat$month,
                                     "-", cat$day)
  }
  else {
    cat$ColDateVisitedFrom <- paste0(cat$DarYearCollected,
                                     "-", cat$DarMonthCollected,
                                     "-", cat$DarDayCollected)
  }
}

cat$ColDateVisitedFrom <- gsub('\\-\\-.*', '-', cat$ColDateVisitedFrom)
cat$ColDateVisitedFrom <- gsub('\\-$', '', cat$ColDateVisitedFrom)


# Setup ISO(ish) dates for the following fields
cat$modified <- date_fixer(cat, "modified", "DarDateLastModified")
cat$eventDate <- date_fixer(cat, "eventDate", "ColDateVisitedFrom")


# Check/Replace carriage returns
cat2 <- piper(cat)


#### Output ####

if(!dir.exists("data02output")) {
  
  dir.create("data02output")
  print("created 'output' directory")
  
}

csv_path <- "data02output/"
                         
print("Outputing prepped file here: data02output/Catalog2.csv")

# Write out results
write_csv(cat2, 
          na = "",
          file = paste0(csv_path,"Catalog2.csv"))
