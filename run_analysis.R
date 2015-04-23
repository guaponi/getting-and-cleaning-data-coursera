library(dplyr)
library(tidyr)

# 
# Some description of data : 
#   http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
#

# 30 volunteers within an age bracket of 19-48 years
# Six recorded activities
# WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING

# where 70% of the volunteers was selected for generating the training data and 30% 
# the test data

if(!file.exists("Dataset.zip")) { 
  url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  destfile <- "Dataset.zip"
  download.file(url = url ,destfile = destfile)
  unzip(zipfile = destfile)
}

# # Instructions
# 1/ Merges the training and the test sets to create one data set.

# Read in the train data and perform the most basic checks to see that data looks ok
trainData <- read.table("./UCI HAR Dataset/train/X_train.txt") 
trainData <- tbl_df(trainData) # Source: local data frame [7,352 x 561]

# Read in the test data
testData <- read.table("./UCI HAR Dataset/test/X_test.txt")
testData <- tbl_df(testData) # Source: local data frame [2,947 x 561]

# Read in train label
trainLabel <- read.table("./UCI HAR Dataset/train/y_train.txt")
trainLabel <- tbl_df(trainLabel) # [1] 7352    1

# Read in test label
testLabel <- read.table("./UCI HAR Dataset/test/y_test.txt") 
testLabel <- tbl_df(testLabel) # [1] 2947    1

# Read in train subject
trainSubject <- read.table("./UCI HAR Dataset/train/subject_train.txt")
trainSubject <- tbl_df(trainSubject) # 7352

# Read in test subject
testSubject <- read.table("./UCI HAR Dataset/test/subject_test.txt")
testSubject <- tbl_df(testSubject) # 2947

# Read in features
features <- read.table("./UCI HAR Dataset/features.txt")
features <- tbl_df(features)


# Add a column with test/traing labels to easier localize origin of data
# in case of any problems
testData <- mutate(testData , partition = "test")
trainData <- mutate(trainData , partition = "train")

# rownumbers + features combined (to easier localize origin if any confusion later on)
features <- mutate(features, V3 = paste0(V1, V2)) 
colnames <- features["V3"][[1]]
colnames <- c(colnames, "562mypartion") # dummy variable with train/test labels

# merge train and test data
data <- rbind(testData, trainData)
names(data) <- colnames

# merge train and test subject
subject <- rbind(testSubject, trainSubject)
names(subject) <- "subject"

# merge train and test label
label <- rbind(testLabel, trainLabel)
# Easiest to change labels to real names here 
# but postpones it to step 3 to follow instructions
names(label) <- "label"

# combine all data to a large dataframe
df <- cbind(subject = subject, label = label, data )
df <- tbl_df(df) # Source: local data frame [10,299 x 564]

# clean up so we only keep our merged data in df
current_var <- ls()
current_var <- current_var[current_var!="df"]
rm(list = current_var)


# 2/ Extracts only the measurements on the mean and standard deviation for each measurement. 

# find indices containing "mean(" or "std("
ind1 <- grep(pattern = "mean\\(", x = names(df))
ind2 <- grep(pattern = "std\\(", x = names(df))
# keep label subject and our dummy variable
ind3 <- c(1,2,564)
keep <- c(ind3, ind1, ind2)
keep <- unique(keep) # there should be no duplicated indices keep == unique(keep)
df_red <- df[,keep] # keep reduced dataset, Source: local data frame [10,299 x 69]

# 3/ Uses descriptive activity names to name the activities in the data set

# We have few activities so easiest way is to create a lookuptable 
# (if we instead had very many different activities we would need 
# to read in from file and do some parsing and programatically create a lookuptable or other approaches  )
lut <- c( "1" = "WALKING", "2" = "WALKING_UPSTAIRS", "3" = "WALKING_DOWNSTAIRS", 
          "4" = "SITTING", "5" = "STANDING", "6" = "LAYING")

label <-df_red$label
label2 <- lut[label]
df_red$label <- label2


# 4/ Appropriately labels the data set with descriptive variable names. 
glimpse(df_red) 
# data already have descriptive names added from the feature dataframe in step 1,
# however, what in step 3 is labeled "activity" is here labeled "label" 
# so lets change that
df_red <- rename(df_red, activity = label)

# variable names also starts with the original column number, in case we made an error in the selection
# of variables in step 2 (and to control that we have extracted the correct variables)
# we will keep these numbers until the end (remove when presenting the final data)
# The commented out line below will remove these rownumbers from the variable name
# names(data_tbl) <- gsub("^\\d+","",names(data_tbl))

# 5/ From the data set in step 4, creates a second, independent tidy data set with the average of 
# each variable for each activity and each subject.


data_Summary <- df_red %>% 
  select(-c(`562mypartion`)) %>% # remove the dummy variable
  group_by(subject, activity) %>%
  summarise_each(funs(mean)) 
  

names(data_Summary) <- gsub("^\\d+","",names(data_Summary)) # remove rownumbers from variable names

# clean up so we only keep df_red and data_Summary
current_var <- ls()
current_var <- current_var[!(current_var %in% c("df_red", "data_Summary"))]
#current_var <- current_var[current_var!="df"]
rm(list = current_var)

# write out data to file 
write.table(x = data_Summary, file = "data_summary.txt", row.names = FALSE) 

