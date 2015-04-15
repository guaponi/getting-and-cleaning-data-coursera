
if(!file.exists("Dataset.zip")) { 
  url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  destfile <- "Dataset.zip"
  download.file(url = url ,destfile = destfile)
}

# let's see 
