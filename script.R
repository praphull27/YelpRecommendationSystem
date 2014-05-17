install.packages("rjson")
install.packages("irlba")
install.packages("MASS")
library("rjson")
library("irlba")
library("MASS")

businessDatasetFile <- "Dataset/yelp_academic_dataset_business.json"
businessDatasetFileHandle <- file(businessDatasetFile,open="r")
businessDatasetFileLines <- readLines(businessDatasetFileHandle)
numberOfBusinesses <- length(businessDatasetFileLines)
businesses <- matrix(,nrow=1,ncol=numberOfBusinesses)
for (i in 1:numberOfBusinesses) {
	businessJSON <- fromJSON(businessDatasetFileLines[i],method="C")
	businesses[i] <- businessJSON$business_id
}
close(businessDatasetFileHandle)

userDatasetFile <- "Dataset/yelp_academic_dataset_user.json"
userDatasetFileHandle <- file(userDatasetFile,open="r")
userDatasetFileLines <- readLines(userDatasetFileHandle)
numberOfUsers <- length(userDatasetFileLines)
users <- matrix(,nrow=1,ncol=numberOfUsers)
for (i in 1:numberOfUsers) {
	userJSON <- fromJSON(userDatasetFileLines[i],method="C")
	users[i] <- userJSON$user_id
}
close(userDatasetFileHandle)

reviewDatasetFile <- "Dataset/yelp_academic_dataset_review.json"
reviewDatasetFileHandle <- file(reviewDatasetFile,open="r")
reviewDatasetFileLines <- readLines(reviewDatasetFileHandle)
numberOfReviews <- length(reviewDatasetFileLines)
reviews <- matrix(0,nrow=numberOfUsers,ncol=numberOfBusinesses)
for (i in 1:numberOfReviews) {
	reviewJSON <- fromJSON(reviewDatasetFileLines[i],method="C")
	reviews[which(users==reviewJSON$user_id, arr.ind=TRUE)[2], which(businesses==reviewJSON$business_id, arr.ind=TRUE)[2]] <- reviewJSON$stars
}
close(reviewDatasetFileHandle)
closeAllConnections()
remove('businessDatasetFileLines', 'userDatasetFileLines', 'reviewDatasetFileLines')

reviews.svd <- svd(reviews)
