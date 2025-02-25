library(DBI)
library(odbc)


# Connection parameters
server <- "eanc56msd67uzct57ylfb5uvlu-pylx6hw7bvqerh334xtq5bwwgy.datawarehouse.fabric.microsoft.com"
database <- "StarBase"
driver <- "ODBC Driver 18 for SQL Server"  # or your installed version

# Create connection with the token
con <- dbConnect(odbc::odbc(),
                 Driver = "ODBC Driver 18 for SQL Server",
                 Server = "eanc56msd67uzct57ylfb5uvlu-pylx6hw7bvqerh334xtq5bwwgy.datawarehouse.fabric.microsoft.com",
                 Database = "StarBase",
                 Authentication = "ActiveDirectoryInteractive")

# Test 1: Basic Connection Test
tryCatch({
  test1 <- dbGetQuery(con, "SELECT 1 AS test")
  print("Test 1 - Basic Connection: SUCCESS")
  print(test1)
}, error = function(e) {
  print("Test 1 - Basic Connection: FAILED")
  print(e)
})

