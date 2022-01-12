# EMu-IPT-Prep
Tools to prep EMu data for IPT

These scripts are part of the FMNH workflow for publishing specimen data from EMu to the [Field Museum IPT](https://fmipt.fieldmuseum.org).
Information on how to structure data/reports from EMu is at the top of each script.

## IPTac.R
  - prepares EMu Catalogue and Multimedia data as an [Audubon Core](https://github.com/tdwg/ac/blob/master/docs/termlist.md) extension for multimedia associated with occurrences.
  - IPTac_v1.R is an older version (pre-CT scan data) for preparing Multimedia with a simpler record structure

## IPTcd.R
  - prepares a [draft] [Collections Description](https://github.com/tdwg/cd) dataset for inventories, accessions, or other data not yet resolved to 'occurrence-level' specificity.

## IPTdwc.R
  - includes checks to help prepare EMu Catalogue data as a [Darwin Core](https://github.com/tdwg/dwc/blob/master/docs/terms/index.md) dataset.

## IPTdwc_dateModFix.R
  - added 2022-jan to convert EMu's DarDateLastModified values to the proper ISO time format for dwc:modified.

## IPTrr.R
  - prepares EMu Catalogue data from the Relationship Tab (AllRelNhTab) as a [Resource Relationship](https://tools.gbif.org/dwca-validator/extension.do?id=dwc:ResourceRelationship) extension for occurrences with interactions.

## IPTrr_PreDev.R
  - prepares EMu Catalogue data (pre-EMu-development) as a [Resource Relationship](https://tools.gbif.org/dwca-validator/extension.do?id=dwc:ResourceRelationship) extension for occurrences with interactions.
    - see the [Relationship Data workflows doc](https://docs.google.com/document/d/1zvmyEmAilPAmcY1MF-m1I9ZVlDqL6ah170nUez-kR4k/edit#heading=h.tc44y8ytraq5) for help with EMu data handling and IPT mapping.
  - try [an online version here](https://kate-webbink.shinyapps.io/IPTrr_app/)


# Setup
## 1. Install R, RStudio, and Dependencies
EMu-IPT-Prep scripts primarily use tidyverse's `tidyr` and `readr` packages. For more info, check the [tidyverse site](www.tidyverse.org)
1. Download and install [R](https://cran.r-project.org/bin/windows/base/) and [RStudio](https://www.rstudio.com/products/rstudio/download/#download)
2. In RStudio, install the required tidyverse packages in the 'Console' pane (usually lower-left) by typing the following and hitting enter:
    `install.packages('tidyverse')`

## 2. Get Data from EMu
Input for each script is a CSV dataset, reported out of EMu.  See the header-comments in each script for the recommended CSV report, and where the put the output CSV file/s.

## 3. Clone or Download this repo
1. To clone the repo, [UChicago's steps here](https://cfss.uchicago.edu/setup/git-with-rstudio/) are helpful.

Or:
1. Simply download the [EMu-IPT-prep](https://github.com/fieldmuseum/EMu-IPT-Prep) repo as a .zip, and unzip it
2. Open RStudio, and create a new project by going to File --> New Project --> Existing Directory (select the 'EMu-IPT-prep' directory), and clicking 'Create Project'

## 4. Run a Script
Scripts can be run using R's `source()` function if input-files are named properly and in the right directory.
When running `source`, setting `verbose=TRUE` can be useful if warnings or errors pop up. After running a script, cross-checking the input- and output-data in a text-editor -- or in RStudio's 'Environment' pane (usually upper right) -- is recommended.
1. In RStudio, make sure you're in the EMu-IPT-prep project (The top of the RStudio window should show the project directory path. If it's wrong, go to File -> Open Project -> go to the EMu-IPT-prep dir, and open its '.RProj' file).
2. Run the `source` function in the Console pane by typing `source("[script-filename]", verbose=TRUE)` and hitting enter -- e.g.:

    `source("IPTac.R", verbose=TRUE)`

3. While the script is running, a small red 'stop sign' icon will display in the Console pane's upper-right corner. When the script is finished, the stop sign will disappear.
4. When the script finishes, check for the output file/s in the `data02output` directory in this repo.


# To do:
- Add example input/output data
- More how-to, validation, error logging...
- Finish draft-CD script  
