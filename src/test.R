# This is to test the path.
# The wd() is the project path,
# so we can easily read from the ./data 
# and save to ./outputs.
# I renamed the data file to speedtest.csv
# Paste the file on this location localy and rename it.
# The .gitignore files prevent the sync of the folder contents.
# So, the below .csv will not sync from you laptop to git.
# We don't want that because (i) it's too big for gut and
# (ii) we don't want to have these data public.
# I have similar .gitignore files to other folders
# because git cannot sync empty folders.
# Once we have outputs we can delete these files in
# order to sync their content with git

library(data.table)

getwd()

test <- fread("./data/raw/speedtest.csv")
head(test)
