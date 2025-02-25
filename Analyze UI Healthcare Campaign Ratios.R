library(lubridate)
library(dplyr)
library(DBI)
library(odbc)

con <- dbConnect(odbc::odbc(), 
                 Driver = "ODBC Driver 18 for SQL Server",
                 Server = "edwdevsqlmi01.7afa76e7ae68.database.windows.net",
                 Authentication = "ActiveDirectoryInteractive"
                  )

# define data to be loaded
query <- "
  SELECT     *
  FROM UICARPTS.CPN.CampaignProcess_CampaignGivingDetail R
  JOIN DataScience.raw.stg_DesignationHardened DH
  ON R.DesignationId = DH.DesignationID
  WHERE DH.CollegeCode IN ('DEG', 'MEG', 'NUG', 'PHG', 'PQG', 'HSG', 'MHG')
  AND CampaignDate > '2019-07-01'
  ORDER BY CampaignAmount DESC
  "

# Load the data
data_frame<- dbGetQuery(con, query)

# Confirm the data has been loaded
dimensions<-dim(data_frame)
print(dimensions)

# Create a condensed version of data_frame with only the columns we need
data_frame <- data_frame %>%
  select(CampaignDate, Department, CampaignAmount, Area)

# Summarize data_frame by Department

summary_data_frame <- data_frame %>%
  group_by(Department) %>%
  summarize(Amount_Sum = sum(CampaignAmount, na.rm = TRUE))

# Add a column to summary_data_frame that calculates the ratio of Amount_Sum to the total Amount_Sum
summary_data_frame <- summary_data_frame %>%
  mutate(Ratio = Amount_Sum / sum(Amount_Sum, na.rm = TRUE))

# Export as CSV In current folder
write.csv(summary_data_frame, "UI_Healthcare_Campaign_Ratios.csv", row.names = FALSE)

# Find number of records, oldest and newest record, and total of Amount in data_frame
number_of_records <- nrow(data_frame)
oldest_date <- min(data_frame$CampaignDate)
newest_date <- max(data_frame$CampaignDate)
total_amount <- sum(data_frame$CampaignAmount)

# Print number of records, oldest and newest date with labels
print(paste("Number of records in data_frame:", number_of_records,"Oldest date in data_frame:", oldest_date,"Newest date in data_frame:", newest_date, "Total amount in data_frame:", total_amount))


