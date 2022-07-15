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
conn1 <- OpenDatabaseConnection()
db <- GetRawData(conn)

visit <- db$Visit

spring.info1 <- db$Visit %>%
  filter(SiteCode == params$site.code)

visit.info1 <- spring.info1 %>%
  #  select(-PhotoType, -PhotoLabel, -RenamedFilePath, -UtmX_m, -UtmY_m, -UTMZone, -PhotoNotes) %>%
  unique()


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
