# Ugly hack for CRAN checks
utils::globalVariables(c("."))

##' Gets the publications for a scholar
##'
##' Gets the publications of a specified scholar.
##'
##' @param id a character string specifying the Google Scholar ID.  If
##' multiple IDs are specified, only the publications of the first
##' scholar will be retrieved.
##' @param cstart an integer specifying the first article to start
##' counting.  To get all publications for an author, omit this
##' parameter.
##' @param pagesize an integer specifying the number of articles to
##' fetch
##' @param flush should the cache be flushed?  Search results are
##' cached by default to speed up repeated queries.  If this argument
##' is TRUE, the cache will be cleared and the data reloaded from
##' Google.
##' @details Google uses two id codes to uniquely reference a
##' publication.  The results of this method includes \code{cid} which
##' can be used to link to a publication's full citation history
##' (i.e. if you click on the number of citations in the main scholar
##' profile page), and \code{pubid} which links to the details of the
##' publication (i.e. if you click on the title of the publication in
##' the main scholar profile page.)
##' @return a data frame listing the publications and their details.
##' These include the publication title, author, journal, number,
##' cites, year, and two id codes (see details).
##' @importFrom stringr str_extract str_sub str_trim str_replace
##' @importFrom dplyr "%>%" row_number filter
##' @importFrom xml2 read_html
##' @importFrom rvest html_nodes html_text html_attr
##' @importFrom httr GET
##' @import R.cache
##' @export
get_publications <- function(id, cstart = 0, pagesize=100, flush=FALSE) {

    ## Ensure we're only getting one scholar's publications
    id <- tidy_id(id)

    ## Define the cache path 
    cache.dir <- file.path(tempdir(), "r-scholar")
    setCacheRootPath(cache.dir)
    
    ## Clear the cache if requested
    if (flush) saveCache(NULL, key=list(id, cstart))

    ## Check if we've cached it already
    data <- loadCache(list(id, cstart))

    ## If not, get the data and save it to cache
    if (is.null(data)) {
  
        ## Build the URL
        url_template <- "http://scholar.google.com/citations?hl=en&user=%s&cstart=%d&pagesize=%d"
        url <- sprintf(url_template, id, cstart, pagesize)

        ## Load the page
        page <- GET(url, handle=getOption("scholar_handle")) %>% read_html()
        cites <- page %>% html_nodes(xpath="//tr[@class='gsc_a_tr']") 

        title <- cites %>% html_nodes(".gsc_a_at") %>% html_text()
        pubid <- cites %>% html_nodes(".gsc_a_at") %>%
            html_attr("href") %>% str_extract(":.*$") %>% str_sub(start=2)
        doc_id <- cites %>% html_nodes(".gsc_a_ac") %>% html_attr("href") %>%
            str_extract("cites=.*$") %>% str_sub(start=7)
        cited_by <- suppressWarnings(cites %>% html_nodes(".gsc_a_ac") %>%
                                     html_text() %>%
                                     as.numeric(.) %>% replace(is.na(.), 0))
        year <- cites %>% html_nodes(".gsc_a_y") %>% html_text() %>%
            as.numeric()
        authors <- cites %>% html_nodes("td .gs_gray") %>% html_text() %>%
            as.data.frame(stringsAsFactors=FALSE) %>%
                filter(row_number() %% 2 == 1)  %>% .[[1]]
    
        ## Get the more complicated parts
        details <- cites %>% html_nodes("td .gs_gray") %>% html_text() %>%
            as.data.frame(stringsAsFactors=FALSE) %>%
                filter(row_number() %% 2 == 0) %>% .[[1]]


        ## Clean up the journal titles (assume there are no numbers in
        ## the journal title)
        first_digit <- as.numeric(regexpr("[\\[\\(]?\\d", details)) - 1
        journal <- str_trim(str_sub(details, end=first_digit)) %>%
            str_replace(",$", "")

        ## Clean up the numbers part
        numbers <- str_sub(details, start=first_digit) %>%
            str_trim() %>% str_sub(end=-5) %>% str_trim() %>% str_replace(",$", "")

        ## Put it all together
        data <- data.frame(title=title,
                           author=authors,
                           journal=journal,
                           number=numbers,
                           cites=cited_by,
                           year=year,
                           cid=doc_id,
                           pubid=pubid)
        
        ## Check if we've reached pagesize articles. Might need
        ## to search the next page
        if (nrow(data) > 0 && nrow(data)==pagesize) {
            data <- rbind(data, get_publications(id, cstart=cstart+pagesize, pagesize=pagesize))
        }
    
        ## Save it after everything has been retrieved.
        if (cstart == 0) {
            saveCache(data, key=list(id, cstart))
        }
    }
  
    return(data)
}

##' Gets the citation history of a single article
##'
##' @param id a character string giving the id of the scholar
##' @param article a character string giving the article id.
##' @return a data frame giving the year, citations per year, and
##' publication id
##' @importFrom dplyr "%>%"
##' @importFrom stringr str_replace
##' @importFrom xml2 read_html
##' @importFrom rvest html_nodes html_attr html_text
##' @importFrom httr GET
##' @export
get_article_cite_history <- function (id, article) {
    
    id <- tidy_id(id)
    url_base <- paste0("http://scholar.google.com/citations?", 
                       "view_op=view_citation&hl=en&citation_for_view=")
    url_tail <- paste(id, article, sep=":")
    url <- paste0(url_base, url_tail)

    doc <- GET(url, handle=getOption("scholar_handle")) %>% read_html()

    ## Inspect the bar chart to retrieve the citation values and years
    years <- doc %>%
        html_nodes(xpath="//*/div[@id='gsc_graph_bars']/a") %>%
            html_attr("href") %>%
                str_replace(".*as_yhi=(.*)$", "\\1") %>%
                    as.numeric()
    vals <- doc %>%
        html_nodes(xpath="//*/span[@class='gsc_g_al']") %>%
            html_text() %>%
                as.numeric()

    df <- data.frame(year = years, cites = vals)

    ## There may be undefined years in the sequence so fill in these gaps
    tmp <- merge(data.frame(year=min(years):max(years)),
                 df, all.x=TRUE)
    tmp[is.na(tmp)] <- 0

    tmp$pubid <- article
    return(tmp)
}

##' Calculates how many articles a scholar has published
##'
##' Calculate how many articles a scholar has published.
##'
##' @param id a character string giving the Google Scholar ID
##' @return an integer value (max 100)
##' @export
get_num_articles <- function(id) {  
    papers <- get_publications(id)
    return(nrow(papers))
}

##' Gets the year of the oldest article for a scholar
##'
##' Gets the year of the oldest article published by a given scholar.
##' 
##' @param id 	a character string giving the Google Scholar ID
##' @return the year of the oldest article
##' @export
get_oldest_article <- function(id) {
    papers <- get_publications(id)
    return(min(papers$year, na.rm=TRUE))
}


