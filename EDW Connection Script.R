library(DBI)
library(odbc)

con <- dbConnect(odbc::odbc(), 
    Driver = "ODBC Driver 18 for SQL Server",
    Server = "edwdevsqlmi01.7afa76e7ae68.database.windows.net",
    Authentication = "ActiveDirectoryInteractive"
)
    
    