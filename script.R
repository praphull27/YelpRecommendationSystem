library("rjson")
library("irlba")

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
closeAllConnections()
remove('businessDatasetFile', 'businessDatasetFileHandle', 'businessDatasetFileLines', 'businessJSON')
gc()

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
closeAllConnections()
remove('userDatasetFile', 'userDatasetFileHandle', 'userDatasetFileLines', 'userJSON')
gc()

ptm <- proc.time()
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
remove('reviewDatasetFile', 'reviewDatasetFileHandle', 'reviewDatasetFileLines', 'reviewJSON')
gc()
ptm <- proc.time() - ptm
cat ("Time taken to build the reviews matrix\n")
print(ptm)

ptm <- proc.time()
reviewsSVDRank100 <- irlba(reviews, nu=100, nv=100)
ptm <- proc.time() - ptm
cat ("Time taken to perform SVD using irlba\n")
print(ptm)

gc()

reviewsSVDRank100$D <- diag(reviewsSVDRank100$d)

ptm <- proc.time()
weightMatrix <- matrix(0,nrow=numberOfUsers,ncol=numberOfBusinesses)
Wlocations <- which (reviews != 0, arr.ind=T)
for (i in 1:dim(Wlocations)[1]) {
	weightMatrix[Wlocations[i,1], Wlocations[i,2]] = 1
}
remove('Wlocations')
gc()
ptm <- proc.time() - ptm
cat ("Time taken to calculate weight matrix\n")
print(ptm)

save.image()

minRank <- 0
minNorm <- -1

ptm <- proc.time()
for (i in 2:100) {
	u <- reviewsSVDRank100$u[,1:i]
	D <- reviewsSVDRank100$D[1:i,1:i]
	v <- t(reviewsSVDRank100$v[,1:i])
	T <- D %*% v
	remove('D', 'v')
	LRARank <- u %*% T
	remove('u', 'T')
	W <- LRARank * weightMatrix
	diff <- reviews - W
	remove('W')
	fNorm <- norm(diff, "F")
	remove('diff')
	cat ("Fnorm for Rank ", i, " = ", fNorm, "\n")
	if (minNorm == -1) {
		minNorm <- fNorm
		minRank <- i
	} else if (minNorm > fNorm) {
		minNorm <- fNorm
		minRank <- i
	}
	gc()
}
remove('LRARank', 'fNorm')

save.image()

ptm <- proc.time() - ptm
cat ("Time taken to calculate fnorm for each rank\n")
print(ptm)

cat("\n\n")
cat("***************")
cat("Rank with minimum fNorm is ", minNorm, "\n")
cat("Lowest fNorm is ", minRank, "\n")
cat("***************")
cat("\n\n")
