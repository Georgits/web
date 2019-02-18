url <-'https://www.amazon.de/thriller-spannende-b%C3%83%C2%BCcher-krimis/b/ref=amb_link_14?ie=UTF8&node=287480&pf_rd_m=A3JWKAKR8XB7XF&pf_rd_s=merchandised-search-left-2&pf_rd_r=2NVPSHETJHYK0RKNJ9BH&pf_rd_r=2NVPSHETJHYK0RKNJ9BH&pf_rd_t=101&pf_rd_p=e63414b0-956b-499a-83a2-182e2cc3a2d4&pf_rd_p=e63414b0-956b-499a-83a2-182e2cc3a2d4&pf_rd_i=186606'
url_1 <- 'https://www.xing.com/contacts/contacts?page=1&initial=&order_by=last_name&cities%5B%5D=&companies%5B%5D=&tags%5B%5D=&no_tags=&query=&view_type=condensed&custom_url=false'
url_2 <- 'https://www.xing.com'




library(rvest)
library(RSelenium)
remDr <- remoteDriver(
  remoteServerAddr = "localhost",
  port = 4445L,
  browserName = "firefox"
)
url <- 'https://www.xing.com'
url_start <- 'https://www.xing.com/contacts/contacts?page=1&initial=B&order_by=last_name&cities%5B%5D=&companies%5B%5D=&tags%5B%5D=&no_tags=&query=&view_type=condensed&custom_url=true'

remDr$open()


remDr$navigate(url)

pgsession <-html_session(url)
pgform    <-html_form(pgsession)[[2]]

filled_form <- set_values(pgform, 'login_form[username]' = "tsertsvadze", 'login_form[password]' = "Ctqvxy_24")
submit_form(pgsession,filled_form)


html <- read_html(remDr$getPageSource()[[1]])

s <- jump_to(pgsession, url)
page <- read_html(s)


remDr$navigate(url)
  webElems <- remDr$findElements(using = "css selector", "/html/body/div[1]/main/div[1]/nav/ul[1]/li[3]/a")
resHeaders <- unlist(lapply(webElems, function(x) {x$getElementText()}))
resHeaders


write_xml(page, file="temp.html")



test <- read_html('temp.html')
webElems <- remDr$findElements(using = "css selector", "a")











s <- jump_to(pgsession, url)
  s <- s %>% follow_link(33)
page <- read_html(s)
# %>%
#   html_nodes('.pagnHy')
  # %>% 
  # html_text() 

write_xml(page, file="temp.html")

library(rvest)
se <- html_session( "https://httpbin.org/user-agent" )
se$response$request$options$useragent