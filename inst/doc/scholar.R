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


## ----reusable-publications, eval=FALSE----------------------------------------
# pubs <- get_publications(id)
# 
# recent <- subset(pubs, !is.na(year) & year >= 2020)
# nrow(recent)
# sum(recent$cites, na.rm = TRUE)
# get_publication_metrics(recent)

