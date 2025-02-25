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
  SELECT 
    *
  FROM UICARPTS.CPN.CampaignProcess_CampaignGivingDetail R
  JOIN DataScience.raw.stg_DesignationHardened DH
  ON R.DesignationId = DH.DesignationID
  "

# Load the data
data_frame<- dbGetQuery(con, query)


# Organize data and remove unneeded columns
data_frame <- data_frame %>%
  select(CampaignDate, CampaignUnit, RevenueTransactionType, UseCode, EndowmentCode, CampaignAmount)


# Convert CampaignDate to Fiscal Year
data_frame$FiscalYear <- ifelse(month(data_frame$CampaignDate) >= 7, 
                                year(data_frame$CampaignDate) + 1, 
                                year(data_frame$CampaignDate))


# Characterize CampaignAmount  Gift_Class
data_frame <- data_frame %>%
  mutate(Gift_Class = case_when(
    CampaignAmount >= 25000000 ~ "Transformational",
    CampaignAmount >= 5000000 & CampaignAmount < 25000000 ~ "Principal",
    CampaignAmount >= 50000 & CampaignAmount < 5000000 ~ "Major",
    CampaignAmount <  50000 ~ "Non-Major"
  ))


# Export as CSV In current folder
#write.csv(data_frame, "Campaign Sankey.csv", row.names = FALSE)


# Confirm the data has been loaded
dimensions<-dim(data_frame)
print(dimensions)

# Get Opportunity Data

proposal_query<-"SELECT * FROM UICARPTS.PM.v_Proposals
                WHERE ProposalStage IN ('Committed')
                "
proposal_frame<- dbGetQuery(con, proposal_query)

#proposal_frame<-proposal_frame %>%
#  select(Id, Name, Description, StageName, CloseDate, Amount, FiscalYear, )

# Confirm the data has been loaded
proposal_dimensions<-dim(proposal_frame)
print(proposal_dimensions)

#View oldest date in proposal_frame
min(proposal_frame$CloseDate)

