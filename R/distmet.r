#' Calculates the distance measures
#'
#' @export
#' @param lineup.dat lineup data
#' @param var a vector of names of the variables to be used
#' @param met distance metric needed to calculate the distance as a character
#' @param method method for generating null data sets
#' @param pos position of the observed data in the lineup
#' @param m the number of plots in the lineup; m = 20 by default
#' @param dist.arg a list or vector of inputs for the distance metric met; NULL by default
#' @examples if(require('reshape')) {
#' if(require('plyr')) { distmet(lineup(null_permute('mpg'), mtcars, pos =
#' 10), var = c('mpg', 'wt'), 'reg_dist', null_permute('mpg'), pos = 10) }}
#' if(require('reshape')) {
#' if(require('plyr')) {
#' distmet(lineup(null_permute('mpg'), mtcars, pos = 10), var = c('mpg', 'wt'), 'bin_dist', 
#' null_permute('mpg'), pos = 10, dist.arg = list(X.bin = 5, Y.bin =
#' 5)) }}
distmet <- function(lineup.dat, var, met, method, pos, dist.arg = NULL, m = 20) {
    lineup.dat <- lineup.dat[, c(var, ".sample")]
    if (!is.character(met)) {
        stop("function met should be a character")
    }
    func <- match.fun(met)
    if (as.character(met) == "bin_dist") {
        dist.arg <- list(lineup.dat, dist.arg[[1]], dist.arg[[2]])
    }
    d <- sapply(1:m, function(x) {
        sapply(1:m, function(y) {
            if (is.null(dist.arg)) {
                dis <- do.call(func, list(lineup.dat[lineup.dat$.sample == 
                  x, ], lineup.dat[lineup.dat$.sample == y, ]))
            } else {
                dis <- do.call(func, append(list(lineup.dat[lineup.dat$.sample == 
                  x, ], lineup.dat[lineup.dat$.sample == y, ]), unname(dist.arg)))
            }
        })
    })
    d.m <- melt(d)
    names(d.m) <- c("pos.2", "plotno", "b")
    d <- subset(d.m, plotno != pos.2 & pos.2 != pos)
    dist.mean <- ddply(d, .(plotno), summarize, mean.dist = mean(b), len = length(b))
    diff <- with(dist.mean, mean.dist[len == (m - 1)] - max(mean.dist[len == 
        (m - 2)]))
    closest <- dist.mean[order(dist.mean$mean.dist, decreasing = TRUE), ]$plotno[2:6]
    obs.dat <- lineup.dat[lineup.dat$.sample == pos, ]
    all.samp <- ldply(1:1000, function(k) {
        null <- method(obs.dat)  # method
        Dist <- ldply(1:(m - 2), function(l) {
            null.dat <- method(null)  # method
            if (is.null(dist.arg)) {
                do.call(func, list(null, null.dat))
            } else {
                do.call(func, append(list(null, null.dat), unname(dist.arg)))  # dist.met
            }
        })
        mean(Dist$V1)
    })
    return(list(dist.mean = dist.mean[, c("plotno", dist = "mean.dist")], all.val = all.samp, 
        diff = diff, closest = closest, pos = pos))
}

#' Plotting the distribution of the distances with the distances for 
#' the null plots and true plot overlaid  
#'
#' @param dat output from \code{\link{distmet}}
#' @param m the number of plots in the lineup; m = 20 by default
#' @export
#' @examples if(require('ggplot2')) {
#'	if(require('reshape')) {
#' if(require('plyr')) {distplot(distmet(lineup(null_permute('mpg'), mtcars, pos
#' = 10), var = c('mpg', 'wt'), 'reg_dist', null_permute('mpg'), pos = 10))}}} 
distplot <- function(dat, m = 20) {
    p <- with(dat, qplot(all.val$V1, geom = "density", fill = I("grey80"), 
        colour = I("grey80"), xlab = "Permutation distribution", ylab = "") + 
        geom_segment(aes(x = dist.mean$mean.dist[dist.mean$plotno != pos], 
            xend = dist.mean$mean.dist[dist.mean$plotno != pos], y = rep(0.01 * 
                min(density(all.val$V1)$y), (m - 1)), yend = rep(0.05 * max(density(all.val$V1)$y), 
                (m - 1))), size = 1, alpha = I(0.7)) + geom_segment(aes(x = dist.mean$mean.dist[dist.mean$plotno == 
        pos], xend = dist.mean$mean.dist[dist.mean$plotno == pos], y = 0.01 * 
        min(density(all.val$V1)$y), yend = 0.1 * max(density(all.val$V1)$y)), 
        colour = "darkorange", size = 1) + geom_text(data = dist.mean, y = -0.03 * 
        max(density(all.val$V1)$y), size = 2.5, aes(x = mean.dist, label = plotno)) + 
        ylim(c(-0.04 * max(density(all.val$V1)$y), max(density(all.val$V1)$y) + 
            0.1)))
    return(p)
    
} 
