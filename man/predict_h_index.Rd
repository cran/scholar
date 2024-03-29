% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/predict.r
\name{predict_h_index}
\alias{predict_h_index}
\title{Predicts the h-index for a researcher}
\source{
DE Acuna, S Allesina, KP Kording (2012) Future impact:
Predicting scientific success.  Nature 489,
201-202. \doi{10.1038/489201a}.  Thanks to DE
Acuna for providing the full regression coefficients for each year
ahead prediction.
}
\usage{
predict_h_index(id, journals)
}
\arguments{
\item{id}{a character string giving the Google Scholar ID}

\item{journals}{optional character vector of top
journals. See \code{\link{get_num_top_journals}} for more details.}
}
\value{
a data frame giving predicted h-index values in future
}
\description{
Predicts the h-index for a researcher each year for ten years into
the future using Acuna et al's method (see source).  The model was
fit to data from neuroscience researchers with an h-index greater
than 5 and between 5 to 12 years since publishing their first
article.  So naturally if this isn't you, then the results should
be taken with a large pinch of salt.
}
\details{
Since the model is calibrated to neuroscience
researchers, it is entirely possible that very strange
(e.g. negative) h-indices will be predicted if you are a
researcher in another field.  A warning will be displayed if the
sequence of predicted h-indices contains a negative value or is
non-increasing.
}
\note{
A scientist has an h-index of n if he or she publishes n
papers with at least n citations each.  Values returned are
fractional so it's up to your own vanity whether you want to round
up or down.
}
\examples{
  ## Predict h-index of original method author
\dontrun{
  id <- "DO5oG40AAAAJ"
  df <- predict_h_index(id)
}
}
