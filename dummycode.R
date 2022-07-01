library(desertsprings)
library(dbplyr)
library(dplyr)
library(devtools)

# Setup
park <- "CAMO"
frame <- "3Yr"  #"Annual" or "3Yr"
wateryear <- "2022"
#dest.folder <- paste0("M:/MONITORING/DS_Water/Implementation/SitePackets/PreviousVisitInfo/", wateryear, "/", park) 
dest.folder <- paste0("Data/SiteInfoSheets/",wateryear,"-",park)

#Install DesertSprings package and set up database
install_github("nationalparkservice/mojn-ds-rpackage", ref = "master")
conn <- OpenDatabaseConnection()
db <- GetRawData(conn)

# Get spring info from database
springs <- db$Visit %>%
  select(Park, SiteCode, FieldSeason, SampleFrame) %>%
  unique() %>%
  filter(Park == park, SampleFrame == frame) %>%
  mutate(FileName = paste0(SiteCode, "_", FieldSeason, ".docx"))
  
# Generate info sheets
for (i in 1:nrow(springs)) {
  spring <- springs[i, ]
  #This would be a good spot to add an option to overwrite existing files or not
  rmarkdown::render("site-info.Rmd", output_file = spring$FileName, output_dir = dest.folder, params = list(site.code = spring$SiteCode))
}

## original code
library(tidyverse)
library(pool)
library(dbplyr)
library(devtools)

# Setup
park <- "CAMO"
frame <- "3Yr"  #"Annual" or "3Yr"
wateryear <- "2022"
#dest.folder <- paste0("M:/MONITORING/DS_Water/Implementation/SitePackets/PreviousVisitInfo/", wateryear, "/", park) 
dest.folder <- paste0("Data/SiteInfoSheets/",wateryear,"-",park)

# Set up database connection
db.params <- readr::read_csv("M:/MONITORING/DS_Water/Data/Database/ConnectFromR/ds-database-conn.csv") %>%
  as.list()
db.params$drv <- odbc::odbc()
conn <- do.call(dbPool, db.params)

# Get spring info from database
springs <- tbl(conn, in_schema("export", "SourceMostRecent")) %>%
  collect() %>%
  select(Park, SiteCode, FieldSeason, SampleFrame) %>%
  unique() %>%
  filter(Park == park,SampleFrame == frame) %>%
  mutate(FileName = paste0(SiteCode, "_", FieldSeason, ".docx"))

# Close database connection
poolClose(conn)

# Generate info sheets
for (i in 1:nrow(springs)) {
  spring <- springs[i, ]
  #This would be a good spot to add an option to overwrite existing files or not
  rmarkdown::render("site-info.Rmd", output_file = spring$FileName, output_dir = dest.folder, params = list(site.code = spring$SiteCode))
}

  