library(data.table)

path<-getwd()
path_dataset <- file.path(path, "UCI HAR Dataset")

# get training data
sub_train = read.table(file.path(path_dataset,"train","subject_train.txt"))
x_train = read.table(file.path(path_dataset,"train","X_train.txt"))
y_train = read.table(file.path(path_dataset,"train","Y_train.txt"))


# get test data
sub_test =read.table(file.path(path_dataset,"test","subject_test.txt"))
x_test =  read.table(file.path(path_dataset,"test","X_test.txt"))
y_test = read.table(file.path(path_dataset,"test","Y_test.txt"))


#get data column names

features <- read.table(file.path(path_dataset,"features.txt"), col.names=c("featureId", "featureLabel"))

# get activity labels
activities <- read.table(file.path(path_dataset,"activity_labels.txt"), col.names=c("activityId", "activityLabel"))


activities$activityLabel <- gsub("_", "", as.character(activities$activityLabel))

getFeatures <- grep("-mean\\(\\)|-std\\(\\)", features$featureLabel)


# merge the test and training data 
test.train <- rbind(sub_test, sub_train)
names(test.train) <- "subjectId"
X <- rbind(x_test, x_train)
X <- X[, getFeatures]
names(X) <- gsub("\\(|\\)", "", features$featureLabel[getFeatures])
Y <- rbind(y_test, y_train)
names(Y) = "activityId"
activity <- merge(Y, activities, by="activityId")$activityLabel

# now merge the data frames
data <- cbind(test.train, X, activity)

# create the required dataset  
dataDT <- data.table(data)
newData<- dataDT[, lapply(.SD, mean), by=c("subjectId", "activity")]

# create required file
write.table(newData, "tidy_data.txt",row.name=FALSE, sep = "\t")
