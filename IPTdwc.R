# Clean CSVs for DwC

# 1 - run the appropriate specimen "IPT" report from EMu
# 2 - add the output 'ecatalog.csv' to this repo's data01raw/iptSpec/ directory
# 3 - run this IPTdwc.R script

library("readr")
library("tidyr")
library("dplyr")

if(!dir.exists("data01raw/iptSpec")) {
  
  dir.create("data01raw/iptSpec", recursive = T)
  print("A 'data01raw/iptSpec' directory was newly created")
  print("-- Please add your 'ecatalog.csv' to the 'iptSpec' directory")
  
}

#### Import CSVs ####

input_file <- "data01raw/iptSpec/ecatalog.csv"

input_encoding <- guess_encoding(input_file, n_max = 1000)

cat <- read_csv(input_file,
                guess_max = 1000000,
                locale = readr::locale(encoding = input_encoding$encoding[1]))

# # NOTE - make sure file encoding is properly imported
# # IF grepl("Ã", cat[1:NCOL(cat)]) > 0 ), REIMPORT

#### Setup Cleanup Functions: ####

# # Function to check & fix YYYY-MM-DD date fields to ISO date-format
date_fixer <- function (df_to_fix=cat,
                        column_to_fix,
                        backup_column) {
  
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
    
    print(paste0("Converting dates for '",
                 column_to_fix,
                 "' field..."))
    
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


# Function to fix hard-coded EMu DarBasisOfRecord

basis_fixer <- function (df_to_fix=cat,
                         column_to_fix,
                         backup_column) {
  
  if (nchar(backup_column) > 0) {
    if (!column_to_fix %in% colnames(df_to_fix)) {
      
      if (backup_column %in% colnames(df_to_fix)) {
        df_to_fix[[column_to_fix]] <- df_to_fix[[backup_column]]
      }
      
      else {
        
        print(paste("Warning - For basis_fixer(), input dataframe",
                    df_to_fix, "missing 'column_to_fix'",
                    column_to_fix, "or 'backup_column'", 
                    backup_column))
        
      }
    }
  }
  
  if (column_to_fix %in% colnames(df_to_fix)) {
    
    # Align EMu DarBasisOfRecord-values to dwc:basisOfRecord
    # http://rs.tdwg.org/dwc/dwctype.htm
    print(paste0("Checking/Fixing dwc:basisOfRecord values in '",
                 column_to_fix,
                 "' field..."))
    
    # Remove spaces, if any
    df_to_fix[[column_to_fix]] <- gsub("\\s+",
                                       "", 
                                       df_to_fix[[column_to_fix]])
    
    # Fix overly general terms
    if (df_to_fix[[column_to_fix]][1] == "Specimen") { 
      
      if (!"collectionCode" %in% colnames(df_to_fix)) {
        if (!"CatCatalog" %in% colnames(df_to_fix)) {
          print(paste("Warning - For basis_fixer(), input dataframe",
                      df_to_fix, 
                      "missing 'collectionCode' or 'CatCatalog'. ",
                      "Cannot fix dwc:basisOfRecord"))
          return(df_to_fix[[column_to_fix]])
        } else {
          df_to_fix$collectionCode <- df_to_fix$CatCatalog
        }
      }
        
      if (grepl("Paleo|Fossil\\.*", df_to_fix$collectionCode[1]) > 0) {
        df_to_fix[[column_to_fix]] <- "FossilSpecimen"
      } else {
        df_to_fix[[column_to_fix]] <- "PreservedSpecimen"
      }
    }
    
    return(df_to_fix[[column_to_fix]])
    
  } else {
    
    print(paste("Warning - For basis_fixer(), input dataframe",
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


#### Prep Data-fields ####


# Prep ColDateVisitedFrom if it's missing

if (!'ColDateVisitedFrom' %in% colnames(cat)) {
  
  if (!NA %in% match("year|month|day", colnames(cat))) {
    cat$ColDateVisitedFrom <- paste0(cat$year,
                                     "-", cat$month,
                                     "-", cat$day)
  }
  else {
    if (!'eventDate' %in% colnames(cat)) {
      cat$ColDateVisitedFrom <- paste0(cat$DarYearCollected,
                                       "-", cat$DarMonthCollected,
                                       "-", cat$DarDayCollected)
    } 
    else {
      
      cat$ColDateVisitedFrom <- cat$eventDate
      
    }
  }
}


cat$ColDateVisitedFrom <- gsub('\\-\\-.*', '-', cat$ColDateVisitedFrom)
cat$ColDateVisitedFrom <- gsub('\\-$', '', cat$ColDateVisitedFrom)


#### Fix ISO dates ####
cat$modified <- date_fixer(cat, "modified", "DarDateLastModified")
cat$eventDate <- date_fixer(cat, "eventDate", "ColDateVisitedFrom")


# #### Fix EMu values for dwc:basisOfRecord ####
# - Default to 'Preserved Specimen'
#   with conditions for 'Material Sample' or 'Fossil Specimen'
cat$basisOfRecord <- "Preserved Specimen"

if ("CatCatalogSubset" %in% colnames(cat)) {
  cat$basisOfRecord[cat$CatCatalogSubset == "Tissue"] <- "Material Sample"
}

if (grepl("Fossil|Paleo", cat$collectionCode) > 0) {
  cat$basisOfRecord <- "Fossil Specimen"
}


#### Fix carriage returns ####
cat2 <- piper(cat)


#### Flag duplicated GUIDs ####
if (NROW(cat2) > 1000) {
  
  print(paste("Counting GUIDs in", NROW(cat2),
              "rows -- May take a minute..."))
}

guid_check <- cat2

# Check/Fix "occurrenceId" capitalization
colnames(guid_check)[colnames(guid_check)=="occurrenceID"] <- "occurrenceId"

if (!"occurrenceId" %in% colnames(guid_check)) {
  # Map the 1st GUID column to occurrenceId if not already
  guid_check$occurrenceId <- 
    guid_check[[colnames(guid_check)[grepl("DarGlobalUniqueIdentifier", 
                                colnames(guid_check))>0][1]]]
}

guids <- dplyr::count(guid_check, occurrenceId)

guids_dups <- guids[guids$n > 1,]

cat_dups <- merge(guid_check[,c("irn","occurrenceId")], guids_dups,
                     by="occurrenceId",
                     all.y = TRUE)

if (NROW(cat_dups) > 0) {
  cat_dups <- unique(cat_dups[,c("irn","occurrenceId","n")])
  
  # Also check duplicated irn's
  #   (If a record in a reported dataset is edited while that report runs,
  #   that record's irn may be duplicated in the output...)
  re_check <- dplyr::count(cat_dups, occurrenceId)
  re_check <- re_check[re_check$n > 1,]
  cat_dups <- cat_dups[cat_dups$occurrenceId %in% re_check$occurrenceId,]

}

if (NROW(cat_dups) > 0) {
  
  output_filename <- "dwc_guid_dups.csv"
  
  print(c(paste("Outputting",NROW(re_check), "duplicate GUIDs in",
                NROW(cat_dups),"records to: "),
          output_filename))
  
  write_csv(cat_dups,
            output_filename)
} else {

  print(paste("No duplicate GUIDS found in input CSV: ", input_file))
  
}

#### Output ####

if(!dir.exists("data02output")) {
  
  dir.create("data02output")
  print("created 'output' directory")
  
}

csv_path <- "data02output/"
                         
print("Outputing prepped file here: data02output/Catalog2.csv")

# Write out results
write_csv(cat2, quote = "all",
          file=paste0(csv_path, "Catalog2.csv"),
          na="")

# write.table(cat2, 
#             file=paste0(csv_path, "Catalog2.csv"),
#             row.names = F, sep=",", na="", col.names = T, quote = TRUE)

