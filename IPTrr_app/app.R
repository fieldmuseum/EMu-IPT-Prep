# Prep Related Resource extension datasets
#
# Input-CSV for this app can be made in 3 steps:
#
# 1. Retrieve EMu Catalog records with related resources
#
# 2. Report with "IPT Related Resource"
#      Generated Group1.csv should include these fields:
#         - irn
#         - DarGlobalUniqueID
#         - RelRelationship_tab
#         - RelNotes
#         - RelObjectsRef_tab.DarGlobalUniqueIdentifier
#             - in report, relabel this "relatedResourceID"
#         - RelObjectsRef_tab.DarScientificName
#
# 3. Save report to [this repo]/data01raw/relationships
#

library(readr)
library(tidyr)

library(shiny)

# Based on https://stackoverflow.com/a/52952668/4963125
#   from Carlos Vecina Tebar

# Define UI for data upload app ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Related Resource data prep"),
  # App subtitle
  h4(HTML("Upload your CSV and click the Download button")),
  
  br(),
  p(a(href = "https://docs.google.com/document/d/190msXiIYgui4zReB4O8-IQXq4Gue0GqQZU3wMCZG_jo/edit#heading=h.tc44y8ytraq5",
      "Follow these instructions"),
      "to set up an input-CSV for this app."),
  p(a(href = "https://github.com/fieldmuseum/EMu-IPT-Prep/blob/master/sampleData/relationships/Group1.csv",
      "See this"),
    "for an example of an input-CSV."),
  br(),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel ----
    sidebarPanel(
      
      # Input: Select a file ----
      fileInput("fileUploaded", "Choose CSV File",
                multiple = FALSE,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv")),
      
      # Output: Download a file ----
      downloadButton('downloadFile', 'Process the file & Download', class= "action"),
      
      # CSS style for the download button ----
      tags$style(type='text/css', "#downloadFile { width:100%; margin-top: 35px;}"),
      
      br(),
      br(),
      p("The output CSV is formatted for the",
        a(href = "https://tools.gbif.org/dwca-validator/extension.do?id=dwc:ResourceRelationship",
          "Resource Relationship extension"))
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Data file ----
      textOutput("done")
      
    )
  )
)
# Define server logic to read selected file ----
server <- function(input, output) {
  
  
  # Download handler in Server
  output$downloadFile <- downloadHandler(
    
    filename = function() {
      paste0("processed",
             gsub("-|\\s+|:", "", Sys.time()), 
             '.csv')
    },
    
    content = function(csv_file) {
      
      originalData <- input$fileUploaded
      
      relat_raw <- read_csv(originalData$datapath)
      
      # Data Prep
      relat <- data.frame("resourceID" = relat_raw$DarGlobalUniqueIdentifier,
                          "relatedResourceID" = relat_raw$relatedResourceID,
                          "relationshipOfResource" = relat_raw$RelRelationship,
                          "scientificName" = relat_raw$DarScientificName, 
                          "RelNotes" = relat_raw$RelNotes,
                          stringsAsFactors = FALSE)
      
     
      relat$Count <- gsub("Count:\\s*|\\s*\\|\\s*ObjURI:.*", "", relat$RelNotes)
      relat$relatedResourceID_2 <- gsub(".*ObjURI:\\s*|\\s*\\|\\s*RecordedByIRN.*", "", relat$RelNotes)
      relat$RecordedByIRN <- gsub(".*RecordedByIRN:\\s*|\\s*\\|\\s*RecordedBySummary.*", "", relat$RelNotes)
      relat$relationshipAccordingTo <- gsub(".*RecordedBySummary:\\s*|\\s*\\|\\s*TaxonIRN.*", "", relat$RelNotes)
      relat$TaxonIRN <- gsub(".*TaxonIRN:\\s*|\\s*\\|\\s*TaxonSummary.*", "", relat$RelNotes)
      relat$scientificName_2 <- gsub(".*TaxonSummary:\\s*|\\s*\\|\\s*Notes.*", "", relat$RelNotes)
      relat$relationshipRemarks <- gsub(".*\\|\\s*Notes:\\s*", "", relat$RelNotes)


      relat <- as.data.frame(sapply(relat, trimws, simplify = FALSE),
                             stringsAsFactors = F)

      relat <- as.data.frame(sapply(relat, gsub, pattern = "NULL", replacement = "",
                                    simplify = FALSE),
                             stringsAsFactors = FALSE)


      # Merge fields mapped to multiple pre-dev fields
      relat$relatedResourceID[is.na(relat$relatedResourceID)==T] <- relat$relatedResourceID_2[is.na(relat$relatedResourceID)==T]
      relat$scientificName[is.na(relat$scientificName)==T] <- relat$scientificName_2[is.na(relat$scientificName)==T]


      # Add placeholders for missing fields
      relat$resourceRelationshipID <- rep("", NROW(relat))
      relat$relationshipEstablishedDate <- rep("", NROW(relat))


      # Prep final export table
      relat_out <- data.frame("resourceRelationshipID" = relat$resourceRelationshipID,
                              "resourceID" = relat$resourceID,
                              "relatedResourceID" = relat$relatedResourceID,
                              "relationshipOfResource" = relat$relationshipOfResource,
                              "relationshipAccordingTo" = relat$relationshipAccordingTo,
                              "relationshipEstablishedDate" = relat$relationshipEstablishedDate,
                              "relationshipRemarks" = relat$relationshipRemarks,
                              "scientificName" = relat$scientificName,
                              stringsAsFactors = FALSE)
      
      # Data Output
      write.csv(relat_out, csv_file,  # originalData, csv_file,  
                row.names = FALSE,
                quote = TRUE,
                na = "")
      
      output$done <- renderText({
        ifelse(!is.null(relat_out),
               "Transformation done!",
               "Error while processing data - check input CSV")
        
      })
      
    }
    
  )
  
  
}

# Create Shiny app ----
shinyApp(ui, server)