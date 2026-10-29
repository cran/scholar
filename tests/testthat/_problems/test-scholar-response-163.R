# Extracted from test-scholar-response.R:163

# prequel ----------------------------------------------------------------------
context("scholar response handling")
scholar_response <- function(status, url = "", headers = NULL) {
    structure(list(status_code = status, url = url, headers = headers),
              class = "response")
}

# test -------------------------------------------------------------------------
withr::local_options(list(scholar_warned = NULL))
with_mocked_bindings(
        scholar_get = function(url, handle) scholar_response(403, "https://scholar.google.com/scholar"),
        scholar_handle = function() NULL,
        scholar_sleep = function(time) NULL,
        {
            expect_warning(
                expect_null(get_scholar_resp("https://scholar.google.com/scholar",
                                             attempts_left = 2)),
                "refused the request")
        },
        .package = "scholar"
    )
