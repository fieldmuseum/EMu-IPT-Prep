# Clean CSVs for DwC

# 1 - run the appropriate specimen "IPT" report
# 2 - add the output 'ecatalog.csv' to the data01raw/iptSpec/ directory
# 3 - run this script

library("readr")


# Import CSVs
cat <- read_csv(file = "data01raw/iptSpec/ecatalog.csv")

# # NOTE - make sure file encoding is properly imported
# # IF grepl("Ã", cat[1:NCOL(cat)]) > 0 ), REIMPORT


# Function to check & replace carriage returns
piper <- function (x) {
  x[1:NCOL(x)] <- sapply(x[1:NCOL(x)],
                         function (y) gsub("\\n|\\r", "|", y))
  return(x)
}


# Check/Replace carriage returns
cat2 <- piper(cat)

csv_path <- "data02output/"
                         
# Write out results
write_csv(cat2, 
          na = "",
          path = paste0(csv_path,"Catalog2.csv"))
