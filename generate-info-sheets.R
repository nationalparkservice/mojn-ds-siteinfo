library(tidyverse)
library(pool)
library(dbplyr)

# Setup
park <- "MOJA"
frame <- "Annual"  #"Annual" or "3Yr"
wateryear <- "22"
#dest.folder <- paste0("M:/MONITORING/DS_Water/Implementation/SitePackets/PreviousVisitInfo/", park) 
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
