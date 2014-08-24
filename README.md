### Introduction
Using a raw dataset of linear and angular velocity and acceleration measurements obtained from subjects performing a number of activities while wearing a suitable equipped smartphone (Samsung Galaxy S II) on the waist, the `run_analysis.R` script performs a number of operations aimed at:

- Obtaining a tidy data set including all observations and variables.
- Providing descriptive labels for the activities performed by the subjects.
- Extracting a subset of the data including only the mean and std deviation variables.
- From the mean and std dev subset, producing an R-readable file which contains, for each subject and activity pair, the mean of each variable.

### Prerequisites
- The raw data, available at <https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip>. The compressed file linked contains a directory, **UCI HAR Dataset**, which once decompressed must be located under R's working directory.
This dataset contains, along with the data, detailed descriptions of methodology, subjects, activities, measurements and files included.
- The **reshape2** R package, available from CRAN.

### Files
- **README.md**, this file.
- **run_analysis.R**, the R script.
- **features_map.txt**, which maps the original variables from the **UCI HAR Dataset**, to the variables in the file output by **run_analysis.R**. As a necessary step of the tidying up process the  original variable names are changed to "R-safe" names. The details of the original variables can be found within the UCI HAR Dataset in the **features.txt** and **features_info.txt**.
- **means.txt**, the product of this process, containing the mean of each variable for each subject and activity pair.

### What does run_analysis.R do...
The work of `run_analysis.R` is divided in the code in five stages.

#### Stage 0 - Preparations
Set up initial references, call reshape2, load and tidy up feature names:
"()" and "-" are deleted, commas are replaced with dots and occurrences of "(" or ")" are replaced with underscores. 

#### Stages 1 & 2 - Load and tidy the test and train raw data subsets
The UCI HAR Dataset is divided in two subsets, "train" and "test". Within these subsets the data is contained in separate space-delimited text files for subjects, activities, activity labels and feature measurements. Stages 1 & 2 in turn combine these text files in two tidy data frames gathering all the data while setting the column names to those arranged in Stage 0.

#### Stage 3 - All together now
The data frames obtained in the previous stages are rbound together and numeric activity ids are replaced with the corresponding descriptive character labels.

#### Stage 4 - Mean & Std Deviation subset
From the result of Stage 3 a subset data frame is built using grep to select the column names containing "mean" or "std".

#### Stage 5 - Summarise and export to file
Finally, the data set is melted() on subject, activity and measurements and then dcast(), aggregating, for each subject + activity pair, on the mean of the measurements.
The resulting data frame is exported using write.table() to **means.txt** on the working directory.
