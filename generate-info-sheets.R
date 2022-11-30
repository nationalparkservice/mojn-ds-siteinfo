library(desertsprings)
library(tidyverse)
library(pool)
library(dbplyr)
library(devtools)

# Setup
park <- "JOTR"
frame <- "3Yr"  #"Annual" or "3Yr"
wateryear <- "2022"
visitdate <- "ALL" #To include all visit notes, set visit.date to "ALL". To include only notes for most recent visit, set to "NA".
#dest.folder <- paste0("M:/MONITORING/DS_Water/Implementation/SitePackets/", park)
dest.folder <- paste0("Data/SiteInfoSheets/",wateryear,"-",park)


#Install DesertSprings package and load data into environment
#install_github("nationalparkservice/mojn-ds-rpackage", ref = "agol-import")
LoadDesertSprings() 
db <- GetRawData()

# Get spring info from database
springs <- db$Visit %>%
  select(Park, SiteCode, SampleFrame) %>%
  unique() %>%
  filter(Park == park, SampleFrame == frame) %>%
  mutate(FileName = paste0(SiteCode, ".docx"))

# Generate info sheets
for (i in 1:nrow(springs)) {
  spring <- springs[i, ]
  #This would be a good spot to add an option to overwrite existing files or not
  rmarkdown::render("site-info.Rmd", output_file = spring$FileName, output_dir = dest.folder, params = list(site.code = spring$SiteCode, visit.date = visitdate))
}

