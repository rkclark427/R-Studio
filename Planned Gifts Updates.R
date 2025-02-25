library(dplyr)
library(DBI)
library(odbc)
library(readxl)

con <- dbConnect(odbc::odbc(), 
                 Driver = "ODBC Driver 18 for SQL Server",
                 Server = "edwdevsqlmi01.7afa76e7ae68.database.windows.net",
                 Authentication = "ActiveDirectoryInteractive"
                 )

# define data to be loaded
query <- "
  SELECT 
    *
  FROM UICARPTS.UICA.PlannedGifts R
  JOIN DataScience.raw.stg_DesignationHardened DH
  ON R.DesignationId = DH.DesignationID
  ORDER BY PlannedGiftID ASC
  "

# Load the data
data_frame<- dbGetQuery(con, query)
id_list<-read_excel("C:/Users/clark/OneDrive - University of Iowa Center for Advancement/Data Analysis/R Sandbox/PlannedGiftsProposedAdditions20250206V2.xlsx")

# Confirm the data has been loaded
dimensions<-dim(data_frame)
print(dimensions)

# Create a condensed version of data_frame with only the columns and rows we need
data_frame_limited_columns <- data_frame %>%
  select(PlannedGiftId, PlannedGiftName, ConstituentName, ProductivityAmount, 
         CampaignTag, College, Department, Area)

dimensions<-dim(data_frame_limited_columns)
print(dimensions)

data_frame_subset<-data_frame_limited_columns %>%
  filter(PlannedGiftId %in% id_list$PlannedGiftId)

dimensions<-dim(data_frame_subset)
print(dimensions)

# Summarize data_frame by Department
summary_data_frame <- data_frame_subset %>%
  group_by(College) %>%
  summarize(Amount_Sum = sum(ProductivityAmount, na.rm = TRUE))

# Export as CSV In current folder
write.csv(summary_data_frame, "Upcoming Planned Gift Additions.csv", row.names = FALSE)




