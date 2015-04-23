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
trainData_tbl <- tbl_df(trainData) # fast look on data, seems ok
rm("trainData")
# trainData_tbl
# Source: local data frame [7,352 x 561]
# print(sum(is.na(trainData_tbl)))
# glimpse(trainData_tbl)

# Read in the test data and perform the most basic checks to see that data looks ok
testData <- read.table("./UCI HAR Dataset/test/X_test.txt")
testData_tbl <- tbl_df(testData)
rm("testData")
# testData_tbl
# Source: local data frame [2,947 x 561]
# print(sum(is.na(testData_tbl)))
# glimpse(testData_tbl)

# Read in train label
trainLabel <- read.table("./UCI HAR Dataset/train/y_train.txt")
trainLabel_tbl <- tbl_df(trainLabel)
dim(trainLabel_tbl) # [1] 7352    1
rm(trainLabel)
table(trainLabel_tbl)

# Read in test label
testLabel <- read.table("./UCI HAR Dataset/test/y_test.txt") 
testLabel_tbl <- tbl_df(testLabel)
rm(testLabel)
dim(testLabel_tbl) # [1] 2947    1
glimpse(testLabel_tbl)
arrange(testLabel_tbl, V1) %>%
  distinct()
#### summarize(testLabel_tbl,V1, length) Incorrect code, check up how to do it in plyr!
table(testLabel_tbl)

# Read in train subject
trainSubject <- read.table("./UCI HAR Dataset/train/subject_train.txt")
trainSubject_tbl <- tbl_df(trainSubject)
rm(trainSubject)
trainSubject_tbl
glimpse(trainSubject_tbl)
nrow(trainSubject_tbl) # 7352
table(trainSubject_tbl)

# Read in test subject
testSubject <- read.table("./UCI HAR Dataset/test/subject_test.txt")
testSubject_tbl <- tbl_df(testSubject)
rm(testSubject)
nrow(testSubject_tbl) # 2947
table(testSubject_tbl)

features <- read.table("./UCI HAR Dataset/features.txt")
features_tbl <- tbl_df(features)
rm(features)

# put everything together into one big matrix
# Just in case there is a problem with test/traing partion of data I will add an extra column with 
# labeled test and training
testData_tbl <- mutate(testData_tbl , partition = "test")
trainData_tbl <- mutate(trainData_tbl , partition = "train")
features_tbl <- mutate(features_tbl, V3 = paste0(V1, V2))
colnames <- features_tbl["V3"][[1]]
colnames <- c(colnames, "562mypartion")

data <- rbind(testData_tbl, trainData_tbl)
names(data) <- colnames


subject <- rbind(testSubject_tbl, trainSubject_tbl)
names(subject) <- "subject"
label <- rbind(testLabel_tbl, trainLabel_tbl)
# it would be easiest to change labels to real names already here but postpones it to step 3
names(label) <- "label"
temp <- cbind(subject = subject, label = label, data )
temp_tbl <- tbl_df(temp)

# clean up
current_var <- ls()
current_var <- current_var[current_var!="temp_tbl"]
rm(list = current_var)


# 2/ Extracts only the measurements on the mean and standard deviation for each measurement. 
# lets look at the variable names
names(temp_tbl)
# let's remove all variables not containing "mean()" or "std()" except "subject", "label", "562mypartion"

ind1 <- grep(pattern = "mean\\(",x = names(temp_tbl))
ind2 <- grep(pattern = "std\\(",x = names(temp_tbl))
ind3 <- c(1,2,564)
keep <- c(ind3, ind1, ind2)
keep <- unique(keep)
data_tbl <- temp_tbl[,keep]

# 3/ Uses descriptive activity names to name the activities in the data set
lut <- c( "1" = "WALKING", "2" = "WALKING_UPSTAIRS", "3" = "WALKING_DOWNSTAIRS", 
          "4" = "SITTING", "5" = "STANDING", "6" = "LAYING")

label <-data_tbl$label
label2 <- lut[label]
data_tbl$label <- label2


# 4/ Appropriately labels the data set with descriptive variable names. 
glimpse(data_tbl)
# data already have descriptive names, however, what in step 3 is labeled "activity" is "label" 
# in my table so lets change that
data_tbl <- rename(data_tbl, activity = label)
# varnames also starts with the original column number
# this can be important later on so I don't remove them 
#(in case there is some confusion about which variables are used )
# however, to remove them later we can use the commented out code below
# names(data_tbl) <- gsub("^\\d+","",names(data_tbl))



# 5/ From the data set in step 4, creates a second, independent tidy data set with the average of 
# each variable for each activity and each subject.


data_Summary <- data_tbl %>%
  group_by(subject, activity) %>%
  summarise_each(funs(mean)) %>%
  select(-c(`562mypartion`))

names(data_Summary) <- gsub("^\\d+","",names(data_Summary))





data_Summary

