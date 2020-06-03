# this is to test the path
# the wd is the project path
# so we can easily read from the ./data 
# and save to ./outputs
# I renamed the data file to speedtest.csv
# Paste the file on this location localy and rename it.

library(data.table)

getwd()

test <- fread("./data/raw/speedtest.csv")
head(test)
