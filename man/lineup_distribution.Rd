% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/quick_plots.R
\name{lineup_distribution}
\alias{lineup_distribution}
\title{Check distributional assumptions using the lineup protocol.}
\usage{
lineup_distribution(
  data,
  variable,
  type = 1,
  dist = NULL,
  params = NULL,
  color_points = "black",
  color_lines = "brown3",
  alpha_points = 0.5
)
}
\arguments{
\item{data}{a data frame.}

\item{variable}{the name of the variable that should be plotted.}

\item{type}{type of plot: 1 = histogram, 2 = Q-Q plot.}

\item{dist}{the null distribution name. One of: beta, cauchy, chisq,
exp, f, gamma, geom, lnorm, logis,
nbinom, binom, norm, pois, t, unif, weibull}

\item{params}{list of parameters of distribution. If \code{NULL}, will
use \code{\link[MASS]{fitdistr}} to estimate them.}

\item{color_points}{the color used for points in the Q-Q plot. Can be a name
or a color HEX code.}

\item{color_lines}{the color used for density and reference lines in the plot.}

\item{alpha_points}{the alpha (opacity) used for points in the Q-Q plot (between
0 and 1, where 1 is opaque).}
}
\value{
a \code{ggplot}
}
\description{
This function is used to quickly create lineup plots to check
distributional assumptions. The null hypothesis is that the data follows
the distribution specified by the \code{dist} argument.
In the lineup protocol the plot of the real data is embedded amongst a field of
plots of data generated to be consistent with some null hypothesis.
If the observe can pick the real data as different from the others, this
lends weight to the statistical significance of the structure in the plot.
The protocol is described in Buja et al. (2009).
}
\details{
Two types of plots are available:

1. Histograms with kernel density estimates.

2. Q-Q plots.

Generate n - 1 null datasets and randomly position the true data.  If you
pick the real data as being noticeably different, then you have formally
established that it is different to with p-value 1/n.
}
\examples{
data(tips)
lineup_distribution(tips, "total_bill", type = 1, dist = "norm") # Histograms
lineup_distribution(tips, "total_bill", type = 1, dist = "gamma") # Histograms
lineup_distribution(tips, "total_bill", type = 2, dist = "norm") # Normal Q-Q plot
lineup_distribution(tips, "total_bill", type = 2, dist = "gamma") # Gamma Q-Q plot

# Style the plot using color settings and ggplot2 functions:
lineup_distribution(tips, "total_bill",
                    type = 1, dist = "gamma",
                    color_lines = "steelblue") +
    ggplot2::theme_minimal()
}
\references{
Buja, Cook, Hofmann, Lawrence, Lee, Swayne, Wickham. (2009).
Statistical inference for exploratory data analysis and model diagnostics,
\emph{Phil. Trans. R. Soc. A}, 367, 4361-4383.
}
\seealso{
null_dist
}
