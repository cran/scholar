# Extracted from test-scholar-response.R:116

# prequel ----------------------------------------------------------------------
context("scholar response handling")
scholar_response <- function(status, url = "", headers = NULL) {
    structure(list(status_code = status, url = url, headers = headers),
              class = "response")
}

# test -------------------------------------------------------------------------
no_indent <- function(txt) expect_false(grepl("\n    [^ ]", txt))
sign_in <- scholar:::scholar_blocked_message(
        scholar_response(200, "https://accounts.google.com/Login"), 200, "sign-in")
expect_match(sign_in, "sign-in page")
no_indent(sign_in)
js_captcha <- scholar:::scholar_blocked_message(
        scholar_response(200, "https://scholar.google.com/scholar?cites=1"),
        200, "captcha-page")
expect_match(js_captcha, "needs JavaScript")
