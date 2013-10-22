## Originally started on 14 May 2013

##' Gets profile information for a scholar
##'
##' Gets profile information for a researcher from Google Scholar.
##' Each scholar profile page gives the researcher's name,
##' affiliation, their homepage (if specified), and a summary of their
##' key citation and impact metrics.  The scholar ID can be found by
##' searching Google Scholar at \url{http://scholar.google.com}.
##' 
##' @param id 	a character string specifying the Google Scholar ID.
##' If multiple ids are specified, only the first value is used and a
##' warning is generated.  See the example below for how to profile
##' multiple scholars.
##' 
##' @return 	a list containing the scholar's name, affiliation,
##' citations, impact metrics, fields of study, and homepage
##' 
##' @examples {
##'    ## Gets profiles of some famous physicists
##'    ids <- c("xJaxiEEAAAAJ", "qj74uXkAAAAJ")
##'    profiles <- lapply(ids, get_profile)
##' }
##' @export
##' @import stringr XML
get_profile <- function(id) {

  id <- tidy_id(id)
  
  url_template <- "http://scholar.google.com/citations?hl=en&user=%s"
  url <- sprintf(url_template, id)

  ## Generate a list of all the tables identified by the scholar ID
  tables <- readHTMLTable(url)
     
  stats <- tables$stats
  ## The citation stats are in tables[[1]]$tables$stats
  ## The personal info is in
  tree <- htmlTreeParse(url, useInternalNodes=TRUE)
  bio_info <- xpathApply(tree, '//*/div[@class="cit-user-info"]//*/form',
                          xmlValue)
  name <- bio_info[[1]]
  affiliation <- bio_info[[2]]
 
  ## Specialities (trim out HTML non-breaking space)
  specs <- iconv(bio_info[[3]], from="UTF8", to="ASCII", sub="zzz")
  specs <- str_trim(tolower(str_split(specs, "z{6}-?")[[1]]))
  specs <- specs[-which(specs=="")]

  ## Extract the homepage
  tmp <- xpathApply(tree, '//form[@id="cit-homepage-form"]//*/a/@href')
  homepage <- as.character(tmp[[1]])
 
  return(list(id=id, name=name, affiliation=affiliation,
              total_cites=as.numeric(as.character(stats[1,2])),
              h_index=as.numeric(as.character(stats[2,2])),
              i10_index=as.numeric(as.character(stats[3,2])),
              fields=specs,
              homepage=homepage))
}

##' Get historical citation data for a scholar
##'
##' Gets the number of citations to a scholar's articles by year.
##' This information is displayed as a bar plot at the top of a
##' standard Google Scholar page.
##'
##' @param id a character string specifying the Google Scholar ID.  If
##' multiple ids are specified, only the first value is used and a
##' warning is generated.  
##' @return a data frame giving the number of citations per year to
##' work by the given scholar
##' @export
##' @import plyr stringr XML
get_citation_history <- function(id) {

  ## Ensure only one ID  
  id <- tidy_id(id)
  
  ## Read the page and parse the key data
  url_template <- "http://scholar.google.com/citations?hl=en&user=%s&pagesize=100&view_op=list_works"
  url <- sprintf(url_template, id)
  
  ## A better way would actually be to read out the plot of citations
  doc <- htmlTreeParse(url, useInternalNodes=TRUE)
  chart <- xpathSApply(doc, "//img", xmlAttrs)[[3]][['src']]

  ## Get values
  vals <- str_extract(chart, "chd=t:((([0-9]*.[0-9]*,+)*)[0-9]*.[0-9])")
  vals <- as.numeric(unlist(str_split(str_sub(vals, 7), ",")))
    
  ## Get the years
  years <- str_extract(chart, "chxl=0:\\|((\\d*)\\|)*\\d*")
  years <- as.numeric(unlist(str_split(str_sub(years, 9), "\\|")))
  years <- years[!is.na(years)]
  years <- seq(years[1], years[length(years)])
    
  ## Get the y-scale
  ymax <- str_extract(chart, "chxr=(\\d*,)*\\d*")
  ymax <- as.numeric(unlist(str_split(str_sub(ymax, 6), ",")))[4]
    
  df <- data.frame(year=years, cites=round(vals*ymax/100, 0))
  
  return(df)
}


##' Gets the number of distinct journals in which a scholar has
##' published
##'
##' Gets the number of distinct journals in which a scholar has
##' published.  Note that Google Scholar doesn't provide information
##' on journals \emph{per se}, but instead gives a title for the
##' containing publication where applicable.  So a \emph{journal} here
##' might actually be a journal, a book, a report, or some other
##' publication outlet.
##' 
##' @param id 	a character string giving the Google Scholar id
##' @return the number of distinct journals
##' @export 
get_num_distinct_journals <- function(id) {
  id <- tidy_id(id)
  papers <- get_publications(id)
  return(length(unique(papers$journal)))
}

##' Gets the number of top journals in which a scholar has published
##'
##' Gets the number of top journals in which a scholar has published.
##' The definition of a 'top journal' comes from Acuna et al. and the
##' original list was based on the field of neuroscience.  This
##' function allows users to specify that list for themselves, or use
##' the default Acuna et al. list.  
##'
##' @source DE Acuna, S Allesina, KP Kording (2012) Future impact:
##' Predicting scientific success.  Nature 489,
##' 201-202. \url{http://dx.doi.org/10.1038/489201a}.
##'
##' @param id 	a character string giving a Google Scholar ID
##' @param journals a character vector giving the names of the top
##' journals.  Defaults to Nature, Science, Nature Neuroscience,
##' Proceedings of the National Academy of Sciences, and Neuron.
##' @export
get_num_top_journals <- function(id, journals) {
  id <- tidy_id(id)
  papers <- get_publications(id)

  if (missing(journals)) {
    journals <-c("Nature", "Science", "Nature Neuroscience",
                 "Proceedings of the National Academy of Sciences", "Neuron")
  }
  
  return(length(which(is.element(papers$journal, journals))))
}

