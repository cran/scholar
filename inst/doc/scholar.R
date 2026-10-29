## -----------------------------------------------------------------------------
#| label: setup
#| echo: false
#| results: hide
knitr::opts_chunk$set(
  tidy = FALSE,
  message = FALSE,
  warning = FALSE,
  fig.width = 7,
  fig.height = 4
)

has_scholar <- yulab.utils::has_internet("https://scholar.google.com")
run_examples <- has_scholar &&
  identical(tolower(Sys.getenv("SCHOLAR_RUN_VIGNETTE_EXAMPLES")), "true")


## -----------------------------------------------------------------------------
#| label: libraries
#| echo: false
#| results: hide
library("scholar")
library("ggplot2")
theme_set(theme_minimal())


## ----ids-basic----------------------------------------------------------------
id <- "B7vSqZsAAAAJ"


## ----tidy-id------------------------------------------------------------------
tidy_id("https://scholar.google.com/citations?user=B7vSqZsAAAAJ&hl=en")
tidy_id("B7vSqZsAAAAJ&hl=en")












## ----all-authors, eval=FALSE--------------------------------------------------
# pubs_full <- get_publications_all_authors(id, pagesize = 20, delay = 1)
# head(pubs_full, 3)














## ----citing-articles, eval=FALSE----------------------------------------------
# pubs <- get_publications(id)
# top <- pubs[which.max(pubs$cites), ]
# get_citing_articles(id, top$pubid, publications = pubs, max_pages = 2)


## ----h-index-history, eval=FALSE----------------------------------------------
# history <- get_h_index_history(id, delay = 1)
# head(history)


## ----h-index-history-plot, eval=FALSE-----------------------------------------
# ggplot(history, aes(year, h_index)) +
#   geom_step(direction = "hv") +
#   labs(x = NULL, y = "h-index",
#        title = "How the h-index accumulated",
#        subtitle = "each step is a year in which another paper reached the threshold")




















## ----journalrank-deprecated, error=TRUE---------------------------------------
try({
get_journalrank(c("Nature", "Science"))
})


## ----openalex-sources, eval=FALSE---------------------------------------------
# openalex <- jsonlite::fromJSON(
#   "https://api.openalex.org/sources?search=Nature&per-page=1")
# openalex$results[, c("display_name", "works_count", "cited_by_count")]
# openalex$results$summary_stats




## ----predict-h-index-custom, eval=FALSE---------------------------------------
# predict_h_index(
#   id,
#   journals = c("Nature", "Science", "Proceedings of the National Academy of Sciences")
# )






## ----mirror, eval=FALSE-------------------------------------------------------
# set_scholar_mirror("https://scholar.google.com")


## ----flush-cache, eval=FALSE--------------------------------------------------
# get_publications(id, flush = TRUE)
# get_scholar_metrics(id, flush = TRUE)


## ----refused, eval=FALSE------------------------------------------------------
# get_profile("B7vSqZsAAAAJ")
# #> Warning: Google Scholar returned a captcha page that needs JavaScript, so the
# #>   response contains no data. ... Carry the session of a browser that opens the
# #>   page with set_scholar_cookie(), ... or run it from a workstation.


## ----reusable-publications, eval=FALSE----------------------------------------
# pubs <- get_publications(id)
# 
# recent <- subset(pubs, !is.na(year) & year >= 2020)
# nrow(recent)
# sum(recent$cites, na.rm = TRUE)
# get_publication_metrics(recent)

