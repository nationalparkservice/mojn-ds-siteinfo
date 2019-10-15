library(tidyverse)
library(pool)
library(dbplyr)

# Setup
park <- "LAKE"
dest.folder <- paste0("M:/MONITORING/DS_Water/Implementation/SitePackets/PreviousVisitInfo/", park) 

# Set up database connection
db.params <- readr::read_csv("M:/MONITORING/DS_Water/Data/Database/ConnectFromR/ds-database-conn.csv") %>%
  as.list()
db.params$drv <- odbc::odbc()
conn <- do.call(dbPool, db.params)

# Get spring info from database
springs <- tbl(conn, in_schema("export", "SiteInfoSheet")) %>%
  collect() %>%
  select(ParkCode, SiteCode, VisitGroup) %>%
  unique() %>%
  filter(ParkCode == park) %>%
  mutate(FileName = paste0(SiteCode, "_", VisitGroup, ".docx"))

# Close database connection
poolClose(conn)

# Generate info sheets
for (i in 1:nrow(springs)) {
  spring <- springs[i, ]
  rmarkdown::render("site-info.Rmd", output_file = spring$FileName, output_dir = dest.folder, params = list(site.code = spring$SiteCode))
}
