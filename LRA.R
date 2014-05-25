Wlocations <- which (reviews != 0, arr.ind=T)

ptm <- proc.time()
for (i in c(89)) {
	u <- reviewsSVDRank100$u[,1:i]
	D <- reviewsSVDRank100$d[1:i]
	v <- t(reviewsSVDRank100$v[,1:i])
	T <- u * D
	remove('u', 'D')
	LRARank <- T %*% v
	remove('T', 'v')

	sum <- 0
	for (i in 1:dim(Wlocations)[1]) {
		sum = sum + (reviews[Wlocations[i,1], Wlocations[i,2]] - LRARank[Wlocations[i,1], Wlocations[i,2]])^2
	}
	fNorm <- sqrt(sum)
	cat ("Fnorm for Rank ", i, " = ", fNorm, "\n")
}
ptm <- proc.time() - ptm
print (ptm)
