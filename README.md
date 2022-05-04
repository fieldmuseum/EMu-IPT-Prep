# EMu-IPT-Prep
Tools to prep EMu data for IPT

These scripts are part of the FMNH workflow for publishing specimen data from EMu to the [Field Museum IPT](https://fmipt.fieldmuseum.org).
Information on how to structure data/reports from EMu is at the top of each script.

## IPTac.R
  - prepares EMu Catalogue and Multimedia data as an [Audubon Core](https://github.com/tdwg/ac/blob/master/docs/termlist.md) extension for multimedia associated with occurrences.
  - IPTac_v1.R is an older version (pre-CT scan data) for preparing Multimedia with a simpler record structure

## IPTcd.R
  - prepares a [draft] [Collections Description](https://github.com/tdwg/cd) dataset for inventories, accessions, or other data not yet resolved to 'occurrence-level' specificity.

## IPTdwc.R [DRAFT]
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

## 2. Clone or Download this repo
1. To clone the repo, [UChicago's steps here](https://cfss.uchicago.edu/setup/git-with-rstudio/) are helpful.

Or:
1. Simply download the [EMu-IPT-prep](https://github.com/fieldmuseum/EMu-IPT-Prep) repo as a .zip, and unzip it
2. Open RStudio, and create a new project by going to File --> New Project --> Existing Directory (select the 'EMu-IPT-prep' directory), and clicking 'Create Project'

## 3. Get Data from EMu
The input files for the EMu-IPT-prep scripts are CSV datasets generated from EMu reports.
In this repo:
- First, create a `data01raw` directory
- Second, create a `data02output` directory

- Run the script's corresponding EMu CSV report and put the output CSVs in the location described below:

  - For Audubon Core scripts, e.g. `IPTac.R`:
    - EMu Catalogue report = 'IPT Audubon Core' CSV report
    - Location for all EMu csv's = `data01raw/`

  - For Darwin Core scripts, e.g. `IPTdwc.R`:
    - run an EMu Catalogue 'IPT_General' CSV report (or IPT_[Collection Area])
    - Note that the file should be the default EMu report name `ecatalog.csv`
    - Location for EMu csv: `data01raw/iptSpec/`

  - For Resource Relationship scripts, e.g. `IPTrr.R`
    - run an EMu Catalogue 'IPT Resource Relationship' CSV report
    - Location for EMu csv: `data01raw/relationships`


## 4a. Run a Script from command line
1. Open command line (cmd, terminal, etc), and check that R can run there by typing `Rscript` and hitting enter.
    - If a 'command not found' warning appears, add Rscript.exe's path (e.g. `C:\Program Files\R\R-4.1.2\bin`) to the Path environment variable 
    - [Steps to add a path are here](https://helpdeskgeek.com/windows-10/add-windows-path-environment-variable/)
2. `cd` to this root directory of this repo
3. Use `Rscript` to run a script in commandline -- e.g.: `Rscript IPTac.R`
    - Use `--verbose` to see more info while the script runs -- e.g.: `Rscript --verbose IPTac.R`
4. When the script finishes, check for the output file/s in the `data02output` directory in this repo.


## 4b. Run a Script from RStudio

Scripts can be run using R's `source()` function if input-files are named properly and in the right directory.
When running `source`, setting `verbose=TRUE` can be useful if warnings or errors pop up. After running a script, cross-checking the input- and output-data in a text-editor -- or in RStudio's 'Environment' pane (usually upper right) -- is recommended.
1. In RStudio, make sure you're in the EMu-IPT-prep project (The top of the RStudio window should show the project directory path. If it's wrong, go to File -> Open Project -> go to the EMu-IPT-prep dir, and open its '.RProj' file).
2. Run the `source` function in the Console pane by typing `source("[script-filename]", verbose=TRUE)` and hitting enter -- e.g.:

    `source("IPTac.R", verbose=TRUE)` # For Audubon Core
    
    `source("IPTdwc.R", verbose=TRUE)` # For Darwin Core

3. While the script is running, a small red 'stop sign' icon will display in the Console pane's upper-right corner. When the script is finished, the stop sign will disappear.
4. When the script finishes, check for the output file/s in the `data02output` directory in this repo.
5. Rename the output file `Catalog2.csv` to the corresponding collection e.g. field_ipt_insects
6. zip the file

# A note on warning messages
`One or more parsing issues, see problems() for details`
- try using guess max tlike this `cat <- read_csv(file = "data01raw/iptSpec/ecatalog.csv", guess_max = 1000000)`
- Basically "guess_max" tells R to look at more rows before guessing which data-types to assign to columns... we could get more strict about schemas, but for now should be good. 

# To do:
- Add example input/output data
- More how-to, validation, error logging...
- Finish draft-CD script  
