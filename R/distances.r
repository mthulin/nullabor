## Distance Metrics -----------------------------------

#' Distance based on the regression parameters
#'
#' @param X a data.frame with two variables, the first column giving
#' the explanatory variable and the second column giving the response
#' variable
#' @param PX another data.frame with two variables, the first column giving
#' the explanatory variable and the second column giving the response
#' variable
#' @return distance between X and PX
#' @export

reg_dist <- function(X, PX, X.bin = 1, Y.bin = X.bin){
	nbins <- X.bin <- Y.bin
	ss <- seq(min(X[,1]), max(X[,1]), length = nbins + 1)
	beta.X <- NULL ; beta.PX <- NULL
	for(k in 1:nbins){
		X.sub <- subset(X, X[,1] >= ss[k] & X[,1] <= ss[k + 1])
		PX.sub <- subset(PX, X[,1] >= ss[k] & X[,1] <= ss[k + 1])
		b.X <- as.numeric(coef(lm(X.sub[,2] ~ X.sub[,1])))
		b.PX <- as.numeric(coef(lm(PX.sub[,2] ~ PX.sub[,1])))
		beta.X <- rbind(beta.X, b.X)
		beta.PX <- rbind(beta.PX, b.PX)
	}
	beta.X <- subset(beta.X, !is.na(beta.X[,2]))
	beta.PX <- subset(beta.PX, !is.na(beta.PX[,2]))
	sum((beta.X[,1] - beta.PX[,1])^2 + (beta.X[,2] - beta.PX[,2])^2)
}

#' Binned Distance
#'
#' euclidean distance is calculated by binning the data and counting the 
#' number of points in each bin
#'
#' @param X a data.frame with two variables, the first two columns 
#' are used
#' @param PX another data.frame with two variables, the first two columns 
#' are used
#' @param X.bin number of bins on the x-direction, by default nbin.X = 5
#' @param Y.bin number of bins on the y-direction, by default nbin.Y = 5
#' @return distance between X and PX
#' @export

bin_dist <- function(X,PX, X.bin = 5, Y.bin = 5) {
	if(!is.numeric(X[,1])){
	X[,1] <- as.numeric(X[,1])
	nij <- as.numeric(table(cut(X[,1], breaks=seq(min(X[,1]), max(X[,1]),length.out = length(unique(X[,1])) + 1), include.lowest = TRUE),cut(X[,2], breaks=seq(min(lineup.dat[,2]), max(lineup.dat[,2]),length.out = Y.bin + 1), include.lowest = TRUE)))
	}else
		nij <- as.numeric(table(cut(X[,1], breaks=seq(min(lineup.dat[,1]), max(lineup.dat[,1]),length.out = X.bin + 1), include.lowest = TRUE),cut(X[,2], breaks=seq(min(lineup.dat[,2]), max(lineup.dat[,2]),length.out = Y.bin + 1), include.lowest = TRUE)))
	if(!is.numeric(PX[,1])){
	PX[,1] <- as.numeric(PX[,1])
	mij <- as.numeric(table(cut(PX[,1], breaks=seq(min(X[,1]), max(X[,1]),length.out = length(unique(X[,1])) + 1), include.lowest = TRUE),cut(PX[,2], breaks=seq(min(lineup.dat[,2]), max(lineup.dat[,2]),length.out = Y.bin + 1), include.lowest = TRUE)))
	}else
	mij <- as.numeric(table(cut(PX[,1], breaks=seq(min(lineup.dat[,1]), max(lineup.dat[,1]),length.out = X.bin + 1), include.lowest = TRUE),cut(PX[,2], breaks=seq(min(lineup.dat[,2]), max(lineup.dat[,2]),length.out = Y.bin + 1), include.lowest = TRUE)))
	sqrt(sum((nij-mij)^2))
}

#' Distance for univariate data
#'
#' distance is calculated based on the first four moments
#'
#' @param X a data.frame where the first column is only used
#' @param PX another data.frame where the first column is only used
#' @return distance between X and PX
#' @export

uni_dist <- function(X, PX){
	xx <- X[, 1]
	yy <- PX[,1]
	stat.xx <- c(mean(xx), sd(xx), moments::skewness(xx), moments::kurtosis(xx))
	stat.yy <- c(mean(yy), sd(yy), moments::skewness(yy), moments::kurtosis(yy))
	sqrt(sum((stat.xx - stat.yy)^2))
}

#' Distance based on side by side Boxplots for two levels
#'
#' distance is calculated by looking at the difference between first
#' quartile, median and third quartile
#'
#' @param X a data.frame with one factor variable and one continuous
#' variable
#' @param PX a data.frame with one factor variable and one continuous
#' variable
#' @return distance between X and PX
#' @export



box_dist <- function(X, PX){
	require(plyr)
	if(!is.factor(X[,1])&!is.factor(X[,2])){
		stop("X should have one factor variable \n \n")
	}else if(is.factor(X[,1])){
		X$group <- X[,1]
		X$val <- X[,2]
		X.sum <- ddply(X, .(group), summarize, sum.stat = quantile(val, c(0.25, 0.5, 0.75)))
	}else if(is.factor(X[,2])){
		X$group <- X[,2]
		X$val <- X[,1]
		X.sum <- ddply(X, .(group), summarize, sum.stat = quantile(val, c(0.25, 0.5, 0.75)))
	}
	if(!is.factor(PX[,1])&!is.factor(PX[,2])){
		stop("PX should have one factor variable \n \n")
	}else if(is.factor(PX[,1])){
		PX$group <- PX[,1]
		PX$val <- PX[,2]
		PX.sum <- ddply(PX, .(group), summarize, sum.stat = quantile(val, c(0.25, 0.5, 0.75)))
	}else {
		PX$group <- PX[,2]
		PX$val <- PX[,1]
		PX.sum <- ddply(PX, .(group), summarize, sum.stat = quantile(val, c(0.25, 0.5, 0.75)))
	}
	abs.diff.X <- abs(X.sum$sum.stat[X.sum$group == levels(X.sum$group)[1]] - X.sum$sum.stat[X.sum$group == levels(X.sum$group)[2]])
	abs.diff.PX <- abs(PX.sum$sum.stat[PX.sum$group == levels(PX.sum$group)[1]] - PX.sum$sum.stat[PX.sum$group == levels(PX.sum$group)[2]])
	sqrt(sum((abs.diff.X - abs.diff.PX)^2))
}


#' Distance based on separation of clusters
#'
#' distance based on the separation between clusters
#' separation is the minimum distances of a point in the cluster to a
#' a point of another cluster
#' @param X a data.frame with two or three columns, the first two columns
#' providing the dataset
#' @param PX a data.frame with two or three columns, the first two columns
#' providing the dataset
#' @param clustering LOGICAL; if TRUE, the third column is used as the 
#' clustering variable, by default FALSE
#' @param nclust the number of clusters to be obtained by hierarchial
#' clustering, by default nclust = 3
#' @return distance between X and PX
#' export

sep_dist <- function(X, PX, clustering = FALSE, nclust = 3){
	require(fpc)
	dX <- dist(X[,1:2])
	dPX <- dist(PX[,1:2])
	if(clustering){
			X$cl <- X[,3]
			PX$cl <- PX[,3]
			X.clus <- cluster.stats(dX, clustering = X$cl)$separation
			PX.clus <- cluster.stats(dPX, clustering = PX$cl)$separation
	}
	else{
	complete.X <- cutree(hclust(dX), nclust)
	complete.PX <- cutree(hclust(dPX), nclust)
	X.clus <- cluster.stats(dX, complete.X)$separation
	PX.clus <- cluster.stats(dPX, complete.PX)$separation
	}
	sqrt(sum((X.clus - PX.clus)^2))
}
