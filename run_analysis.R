## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
## Assignment Data "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" is downloaded
## under working directory and extracted into "UCI HAR Dataset" folder.

install.packages("data.table")

install.packages("reshape2")

require("data.table")
require("reshape2")

# Load activity labels
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")[,2]

# Load data column names
features <- read.table("UCI HAR Dataset/features.txt")[,2]

# Extract only the measurements on the mean and standard deviation for each measurement.
meanstd_features <- grepl("mean|std", features)

# Start reshapping of test data  
# Load and process X_test & y_test data.
X_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")

names(X_test) = features

# Extract only the measurements on the mean and standard deviation for each measurement.
X_test = X_test[,meanstd_features]

# Load activity labels
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

# Bind data
test_data <- cbind(as.data.table(subject_test), y_test, X_test)

# Start reshapping of train data
# Load and process X_train & y_train data.
X_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")

subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")

names(X_train) = features

# Extract only the measurements on the mean and standard deviation for each measurement.
X_train = X_train[,meanstd_features]

# Load activity data
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

# Bind X_train and y_train data using cbind
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

# Merges the training and the test sets to create one data set.
data = rbind(test_data, train_data)

# Uses descriptive activity names to name the activities in the data set
id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
#Melt test and training one data set using id_lables and data_lables
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)


# Apply mean function to dataset using dcast function
# Appropriately labels the data set with descriptive variable names. 
# Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(tidy_data, file = "UCI HAR Dataset/tidy_data.txt", row.names = FALSE)