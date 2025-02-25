library(lubridate)
library(dplyr)
library(DBI)
library(odbc)

# Connection parameters
server <- "eanc56msd67uzct57ylfb5uvlu-pylx6hw7bvqerh334xtq5bwwgy.datawarehouse.fabric.microsoft.com"
database <- "StarBase"
driver <- "ODBC Driver 18 for SQL Server"

# Create connection with the token
con <- dbConnect(odbc::odbc(),
                 Driver = "ODBC Driver 18 for SQL Server",
                 Server = server,
                 Database = database,
                 Authentication = "ActiveDirectoryInteractive")

# define data to be loaded
query<-"SELECT CreatedDate, Name, Description FROM StarBase.raw.stg_ContactReport"

# Load the data
data_frame<- dbGetQuery(con, query)

# Confirm the data has been loaded
dimensions<-dim(data_frame)
print(dimensions)

# append a column with just the numeric month
data_frame$month<-format(as.Date(data_frame$CreatedDate), "%m")

# group by month and count the number of reports for each month (regardless of year)
monthly_report_counts<-data_frame %>% group_by(month) %>% summarise(n=n())

# print the results
print(monthly_report_counts)

# export monthly report counts to Excel
write.csv(monthly_report_counts, "monthly_report_counts.csv")

# graph the results
plot(monthly_report_counts$month, monthly_report_counts$n, type="l", col="blue", xlab="Month", ylab="#Reports", main="Contact Reports by Month")

# find the earliest and latest date in the table
earliest_date<-min(data_frame$CreatedDate)
latest_date<-max(data_frame$CreatedDate)
date_range<-c(earliest_date, latest_date)
print(date_range)

# find number contact reports by year
data_frame$year<-format(as.Date(data_frame$CreatedDate), "%Y")
yearly_report_counts<-data_frame %>% group_by(year) %>% summarise(n=n())
print(yearly_report_counts, n=50)

