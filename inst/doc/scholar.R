## ----style, echo=FALSE, results="asis", message=FALSE-------------------------
knitr::opts_chunk$set(tidy = FALSE,
		   message = FALSE)

has_scholar <- yulab.utils::has_internet("https://scholar.google.com") 

## ----echo=FALSE, results="hide", message=FALSE, eval=has_scholar--------------
library("scholar")
library("ggplot2")
theme_set(theme_minimal())

## ----eval=has_scholar---------------------------------------------------------
## Define the id for Richard Feynman
id <- 'B7vSqZsAAAAJ'

## Get his profile
get_profile(id)

## ----eval=has_scholar---------------------------------------------------------
## Get his publications (a large data frame)
p <- get_publications(id)
head(p, 3)

## ----eval=has_scholar---------------------------------------------------------
## Get his citation history, i.e. citations to his work in a given year
ct <- get_citation_history(id)

## Plot citation trend
library(ggplot2)
ggplot(ct, aes(year, cites)) + geom_line() + geom_point()

## ----eval=has_scholar---------------------------------------------------------
## The following publication will be used to demonstrate article citation history
as.character(p$title[1])

## Get article citation history
ach <- get_article_cite_history(id, p$pubid[1])

## Plot citation trend
ggplot(ach, aes(year, cites)) +
    geom_segment(aes(xend = year, yend = 0), linewidth=1, color='darkgrey') +
    geom_point(size=3, color='firebrick')

## ----eval=has_scholar---------------------------------------------------------
# Compare Feynman and Stephen Hawking
ids <- c('B7vSqZsAAAAJ', 'DO5oG40AAAAJ')

# Get a data frame comparing the number of citations to their work in
# a given year
cs <- compare_scholars(ids)

## ----echo=FALSE, results="hide", message=FALSE--------------------------------
has_cs <- FALSE

if (has_scholar && !is.null(cs)) {
  has_cs <- TRUE
}

## ----eval=has_cs--------------------------------------------------------------
## remove some 'bad' records without sufficient information
cs <- dplyr::filter(cs, !is.na(year) & year > 1900) 

ggplot(cs, aes(year, cites, group=name, color=name)) + 
  geom_line() + theme(legend.position="bottom")

## ----eval=has_scholar---------------------------------------------------------
## Compare their career trajectories, based on year of first citation
csc <- compare_scholar_careers(ids)

## ----echo=FALSE, results="hide", message=FALSE--------------------------------
has_csc <- FALSE

if (has_scholar && !is.null(csc)) {
  has_csc <- TRUE
}

## ----eval=has_csc-------------------------------------------------------------
ggplot(csc, aes(career_year, cites, group=name, color=name)) + 
  geom_line() + geom_point() +
  theme(legend.position = "inside", 
    legend.position.inside=c(.2, .8)
  )

## ----eval=has_scholar---------------------------------------------------------
# Be careful with specifying too many coauthors as the visualization of the
# network can get very messy.
coauthor_network <- get_coauthors('DO5oG40AAAAJ', n_coauthors = 4)

coauthor_network

## ----echo=FALSE, results="hide", message=FALSE--------------------------------
has_coauthor <- FALSE

if (has_scholar && (nrow(coauthor_network) > 1)) {
  has_coauthor <- TRUE
}

## ----eval=has_coauthor--------------------------------------------------------
plot_coauthors(coauthor_network)

## ----results = "asis", eval=has_scholar---------------------------------------
format_publications("DO5oG40AAAAJ", "Guangchuang Yu") |> head() |> cat(sep='\n\n')

## ----results = "asis", eval=has_scholar---------------------------------------
format_publications("DO5oG40AAAAJ", "Guangchuang Yu") |> head() |> print(quote=FALSE)

