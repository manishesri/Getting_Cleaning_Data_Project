library(dplyr)
library(data.table)

setwd("E:/Workspace/Coursera_data_science_project")

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

dst_file <- "data.zip"

if(!file.exists(dst_file)){
  download.file(url, destfile = dst_file, mode = "wb")
}
if(!file.exists("./UCI_HAR_Dataset")){
  unzip(dst_file)
}

setwd("E:/Workspace/Coursera_data_science_project/UCI HAR Dataset")

##load activity files
activity_test <- read.table("./test/y_test.txt", header = FALSE)
activity_train <- read.table("./train/y_train.txt", header = FALSE)

##load feature files
feat_test <- read.table("./test/X_test.txt",header = FALSE)
feat_train <- read.table("./train/X_train.txt",header = FALSE)

##load subject files
sub_test <- read.table("./test/subject_test.txt",header = FALSE)
sub_train <-read.table("./train/subject_train.txt",header = FALSE)


## Read Feature Names
feat_names <- read.table("./features.txt", header = FALSE)

## Read Activity Labels
act_label <- read.table("./activity_labels.txt",header = FALSE)

## Merge the dataset
feat_data <- rbind(feat_test,feat_train)
act_data <- rbind(activity_test,activity_train)
sub_data <- rbind(sub_test,sub_train)

## Rename Columns in Activity Labels and Activity Data
names(act_data) <- "ActivityN"
names(activity_labels) <- c("ActivityN","Activity")

###Get Factor of Acitivity names
Activity <- left_join(act_data,activity_labels,"ActivityN")[,2]

## Rename SubjectData Columns
names(sub_data) <- "Subject"

## Rename Feature Data columns using Feature Names
names(feat_data) <- feat_names$V2

##Merge the Dataset on the basis of following Variables
### 1. Subject Data - sub_data
### 2. Activity - Activity
### 3. Features Data - feat_data

dataset <- cbind(sub_data,Activity)
dataset <- cbind(dataset, feat_data)

## Create New Dataset by Extracting only the measurements on the mean and standard deviation for each measurement. 
subFeatNames <- feat_names$V2[grep("mean\\(\\)|std\\(\\)", feat_names$V2)]
data_names <- c("Subject","Activity", as.character(subFeatNames))
dataset <- subset(dataset,select = data_names)

names(dataset) <-gsub("^t","time", names(dataset))
names(dataset) <- gsub("^f","frequency",names(dataset))
names(dataset) <- gsub("Acc","Accelerometer",names(dataset))
names(dataset) <- gsub("Gyro","Gyroscope",names(dataset))
names(dataset) <- gsub("BodyBody","Body",names(dataset))
names(dataset) <- gsub("Mag","Magnitude",names(dataset))

dataset_2 <- aggregate(.~Subject + Activity, dataset,mean)
dataset_2 <- dataset_2[order(dataset_2$Subject,dataset_2$Activity),]

write.table(dataset_2, file = "tidydata.txt", row.names = FALSE)
