url<- "https://www.bad-homburg.de/rathaus/arbeitgeber-stadt/stellenausschreibungen-Stadt.php"

library(stringr)
library(rvest)
library(RSelenium)
remDr <- remoteDriver(
  remoteServerAddr = "localhost",
  port = 4445L,
  browserName = "firefox"
)

remDr$open()
remDr$navigate(url)

html <- read_html(remDr$getPageSource()[[1]])
webElems <- remDr$findElements(using = "css selector", "li.download")

HG <- unlist(lapply(webElems, function(x) {x$getElementText()}))






HG <-  html %>% 
    # The relevant tag
    html_nodes('li.download') %>%
    html_text() %>% 
    # Trim additional white space
    str_trim() %>%                       
    # Convert the list into a vector
    unlist()


HG_raw<-map_dfc(HG, ~str_split(.x, c("\n")))

test <- HG_raw[c(2,6,9,12),]


# liste <- lapply(openings, function(x) {str_split(x, "\n")})
# lapply(liste, function(x) {x[[1]][[1]][1] <- NULL})



