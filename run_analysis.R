##
## Summary
## 
# Using a raw dataset of linear and angular velocity and acceleration
#+ measurements obtained from subjects performing a number of activities
#+ while wearing a suitable equipped smartphone (Samsung Galaxy S II) on the 
#+ waist, this script performs a number of operations aimed at:
#+
#+ -Obtaining a tidy data set including all observations and variables.
#+ -Providing descriptive labels for the activities performed by the subjects.
#+ -Extracting a subset of the data including only the mean and std deviation 
#+  variables.
#+ -From the mean and std dev subset, producing an R-readable file which
#+  contains, for each subject and activity pair, the mean of each variable.

##
## Prerequisites
##
#  -The raw data in the UCI HAR Dataset directory under the current working dir.
#+  See the README.md file for details on how to obtain it.
#+ -The reshape2 R package, available from CRAN.


##
## STAGE 0 -- Prep
##
# reshape2 will be needed later for melt and dcast
require(reshape2)
# data.dir = the data directory, where the original dataset resides
#+ relative to the working directory
data.dir <- "./UCI HAR Dataset/"
# Load the feature names, we will use them in test.features as colnames
features.names <- read.table(paste(data.dir, "features.txt", sep = ""),
                             colClasses = c("integer","character"),
                             col.names = c("feature_id", "Feature")
                            )
# Polish the feature names a bit, getting rid of characters that might confuse
#+ R but without straying too much from the original names
# First make "()" and "-" vanish
features.names$Feature <- gsub("\\(\\)|-", "", features.names$Feature)
# Next replace "," with "."
features.names$Feature <- gsub(",", ".", features.names$Feature)
# Finally "(" or ")" turned "_"
features.names$Feature <- gsub("\\(|\\)", "_", features.names$Feature)
##
## End Prep Stage
##

##
## STAGE 1 - Test Subset -- build a data frame composed of Subjects, Activities and 
##+ Features from the "test" data subset
##
# Load the list of subjects from the TEST subset into a data frame, as factors
subjects.test <- read.table(paste(data.dir, "test/subject_test.txt", sep = ""),
                            colClasses = "factor")
# Load the list of activities from the TEST subset into a data frame, as factors
activities.test <- read.table(paste(data.dir, "test/y_test.txt", sep = ""),
                              colClasses = "factor")
# Start building the test features table, binding subjects and activities
#+ together
test.features <- cbind(subjects.test, activities.test)
# Make the column names a bit more meaningful
colnames(test.features)[1:2] <- c("Subject", "Activity")
# Load the table of features measured, from the TEST subset into a data frame,
#+ as numeric values
measures.test <- read.table(paste(data.dir, "test/X_test.txt", sep = ""),
                            colClasses = "numeric")


# Set the column names to the appropiate feature using the data loaded in the
#+ Prep Stage
colnames(measures.test)[1:561] <- features.names$Feature
# Finally bind the measured features to the Subjects and Activities
test.features <- cbind(test.features, measures.test)
# be nice, cleanup
rm(list=ls(pattern = ".test"))
##
## End Test Subset Stage
##

##
## STAGE 2 - Train Subset -- build a data frame composed of Subjects, Activities and 
##+ Features from the "train" data subset
##
# Load the list of subjects from the TRAIN subset into a data frame, as factors
subjects.train <- read.table(paste(data.dir, "train/subject_train.txt", sep = ""),
                            colClasses = "factor")
# Load the list of activities from the TRAIN subset into a data frame, as factors
activities.train <- read.table(paste(data.dir, "train/y_train.txt", sep = ""),
                              colClasses = "factor")
# Start building the train features table, binding subjects and activities
#+ together
train.features <- cbind(subjects.train, activities.train)
# Make the column names a bit more meaningful
colnames(train.features)[1:2] <- c("Subject", "Activity")
# Load the table of features measured, from the TRAIN subset into a data frame,
#+ as numeric values
measures.train <- read.table(paste(data.dir, "train/X_train.txt", sep = ""),
                            colClasses = "numeric")


# Set the column names to the appropiate feature using the data loaded in the
#+ Prep Stage
colnames(measures.train)[1:561] <- features.names$Feature
# Finally bind the measured features to the Subjects and Activities
train.features <- cbind(train.features, measures.train)
# keep on being nice, cleanup a bit more
rm(list=ls(pattern = ".train"))
## End Test Subset Stage

##
## STAGE 3 - All Together Now -- bind the test and train subsets into one
##+ and replace the activity ids with labels
##
# Bind the datasets
full.features <- rbind(test.features, train.features)
# Add Activity labels
full.features$Activity <- sapply(full.features$Activity, 
                                 function(x) switch(as.character(x),
                                                    "1" = "WALKING", 
                                                    "2" = "WALKING_UPSTAIRS", 
                                                    "3" = "WALKING_DOWNSTAIRS",
                                                    "4" = "SITTING",
                                                    "5" = "STANDING", 
                                                    "6" = "LAYING")
                                 )
# We do not need the subsets anymore, so wipe them out
rm(list=ls(pattern = "^t.*features$"))
## End All Together Now Stage

##
## STAGE 4 - Extract mean and standard deviation columns
##
# Build a vector of column indexes from the dataset of those column names
#+ containing either "mean" or "std" -- NOTE this vector will not include the
#+ angle*Mean columns for they are not real averages but angle measures between
#+ means
mean.std.columns <- grep("mean|std",names(full.features))
# And extract the mean and std dev columns to a separate data frame, as required
mean.std.features <- full.features[,c(1:2,mean.std.columns)]
## End Extract mean and std dev Stage

##
## STAGE 5 - summarize to a dataset of means and export to file
##
# Reshape on Subject and Activity
melt.features <- melt(mean.std.features, id=c("Subject", "Activity"))
# Aggregate on mean
mean.features <- dcast(melt.features, Subject + Activity ~ variable,
                       fun.aggregate = mean )
# Export to file
write.table(mean.features, file="means.txt", row.names = FALSE)
# Cleanup
rm(melt.features)
## End Extract means of aggregates