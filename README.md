# getting-and-cleaning-data-coursera
getting and cleaning data

## Introduction  
As part of the Getting and Cleaning Data course we aim to solve the following

You should create one R script called run_analysis.R that does the following.   
1. Merges the training and the test sets to create one data set.  
2. Extracts only the measurements on the mean and standard deviation for each measurement.  
3. Uses descriptive activity names to name the activities in the data set  
4. Appropriately labels the data set with descriptive variable names.  
5. From the data set in step 4, creates a second, independent tidy data set with the 
average of each variable for each activity and each subject.  

A full description of the data used can be found at the [UCI machine learning depository](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones).  
Data can be downloaded from [here](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip).

Files used in this project
* README.md (this file)
* Codebook.md 
* run_analysis.R contains code to create a tidy dataset as described above.  
R-packages used are **dplyr** and eventually **tidyr**  
Data used is contained in the *UCI HAR Dataset* folder and it's subfolders. 
Functionallity to download and unzip data is provided in the run_analysis.R script.
