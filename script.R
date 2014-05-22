library("rjson")
library("irlba")

cleanMem <- function(n=10) { for (i in 1:n) gc() }

businessDatasetFile <- "/Users/praphull/gitrepos/YelpRecommendationSystem/Dataset/yelp_academic_dataset_business.json"
businessDatasetFileHandle <- file(businessDatasetFile,open="r")
businessDatasetFileLines <- readLines(businessDatasetFileHandle)
numberOfBusinesses <- length(businessDatasetFileLines)
businesses <- matrix(,nrow=1,ncol=numberOfBusinesses)
for (i in 1:numberOfBusinesses) {
	businessJSON <- fromJSON(businessDatasetFileLines[i],method="C")
	businesses[i] <- businessJSON$business_id
}
close(businessDatasetFileHandle)
closeAllConnections()
remove('businessDatasetFile', 'businessDatasetFileHandle', 'businessDatasetFileLines', 'businessJSON')
cleanMem()

userDatasetFile <- "/Users/praphull/gitrepos/YelpRecommendationSystem/Dataset/yelp_academic_dataset_user.json"
userDatasetFileHandle <- file(userDatasetFile,open="r")
userDatasetFileLines <- readLines(userDatasetFileHandle)
numberOfUsers <- length(userDatasetFileLines)
users <- matrix(,nrow=1,ncol=numberOfUsers)
for (i in 1:numberOfUsers) {
	userJSON <- fromJSON(userDatasetFileLines[i],method="C")
	users[i] <- userJSON$user_id
}
close(userDatasetFileHandle)
closeAllConnections()
remove('userDatasetFile', 'userDatasetFileHandle', 'userDatasetFileLines', 'userJSON')
cleanMem()

ptm <- proc.time()
reviewDatasetFile <- "/Users/praphull/gitrepos/YelpRecommendationSystem/Dataset/yelp_academic_dataset_review.json"
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
remove('reviewDatasetFile', 'reviewDatasetFileHandle', 'reviewDatasetFileLines', 'reviewJSON')
cleanMem()
proc.time() - ptm

ptm <- proc.time()
reviewsSVDRank50 <- irlba(reviews, nu=50, nv=50)
proc.time() - ptm

cleanMem()

reviewsSVDRank50$D <- diag(reviewsSVDRank50$d)

ptm <- proc.time()
weightMatrix <- matrix(0,nrow=numberOfUsers,ncol=numberOfBusinesses)
Wlocations <- which (reviews != 0, arr.ind=T)
for (i in 1:dim(Wlocations)[1]) {
	weightMatrix[Wlocations[i,1], Wlocations[i,2]] = 1
}
remove('Wlocations')
cleanMem()
proc.time() - ptm

minRank <- 0
minNorm <- -1

ptm <- proc.time()
for (i in 2:50) {
	LRARank <- reviewsSVDRank50$u[,1:i] %*% reviewsSVDRank50$D[1:i,1:i] %*% t(reviewsSVDRank50$v[,1:i])
	fNorm <- norm((reviews - (LRARank * weightMatrix)), "F")
	cat ("Fnorm for Rank ", i, " = ", fNorm, "\n")
	if (minNorm == -1) {
		minNorm <- fNorm
		minRank <- i
	} else if (minNorm > fNorm) {
		minNorm <- fNorm
		minRank <- i
	}
	cleanMem()
}
remove('LRARank', 'fNorm')

proc.time() - ptm

cat("\n\n")
cat("***************")
cat("Rank with minimum fNorm is ", minNorm, "\n")
cat("Lowest fNorm is ", minRank, "\n")
cat("***************")
cat("\n\n")
