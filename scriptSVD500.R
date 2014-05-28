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
reviewsSVDRank2 <- irlba(reviews, nu=2, nv=2)
ptm <- proc.time() - ptm
cat ("Time taken to perform SVD using irlba\n")
print(ptm)

gc()

save(list = ls(all = TRUE), file = "SVD2.RData")

Wlocations <- which (reviews != 0, arr.ind=T)

minRank <- 0
minNorm <- 10000
minLRAmatrix <- matrix(0,nrow=numberOfUsers,ncol=numberOfBusinesses)


ptm <- proc.time()
for (i in 1:2) {
	u <- reviewsSVDRank2$u[,1:i]
	D <- reviewsSVDRank2$d[1:i]
	v <- t(reviewsSVDRank2$v[,1:i])
	T <- u * D
	remove('u', 'D')
	LRARank <- T %*% v
	remove('T', 'v')

	sum <- 0
	for (j in 1:dim(Wlocations)[1]) {
		sum = sum + (reviews[Wlocations[j,1], Wlocations[j,2]] - LRARank[Wlocations[j,1], Wlocations[j,2]])^2
	}
	fNorm <- sqrt(sum)
	cat ("Fnorm for Rank ", i, " = ", fNorm, "\n")

	if (minNorm > fNorm) {
		minNorm <- fNorm
		minRank <- i
		minLRAmatrix <- LRARank
	}
	remove('LRARank', 'fNorm', 'sum')
	gc()
}
ptm <- proc.time() - ptm
print (ptm)

save(list = ls(all = TRUE), file = "SVD2withLRA.RData")
