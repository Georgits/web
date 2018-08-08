library(rvest)


url <-'https://www.amazon.de/thriller-spannende-b%C3%83%C2%BCcher-krimis/b/ref=amb_link_14?ie=UTF8&node=287480&pf_rd_m=A3JWKAKR8XB7XF&pf_rd_s=merchandised-search-left-2&pf_rd_r=2NVPSHETJHYK0RKNJ9BH&pf_rd_r=2NVPSHETJHYK0RKNJ9BH&pf_rd_t=101&pf_rd_p=e63414b0-956b-499a-83a2-182e2cc3a2d4&pf_rd_p=e63414b0-956b-499a-83a2-182e2cc3a2d4&pf_rd_i=186606'
url_1 <- 'https://www.xing.com/contacts/contacts?page=1&initial=&order_by=last_name&cities%5B%5D=&companies%5B%5D=&tags%5B%5D=&no_tags=&query=&view_type=condensed&custom_url=false'
url_2 <- 'https://www.xing.com'

pgsession <-html_session(url_2)

pgform    <-html_form(pgsession)[[2]]


filled_form <- set_values(pgform, 'login_form[username]' = "tsertsvadze", 'login_form[password]' = "ctqvxy")


submit_form(pgsession,filled_form)

s <- jump_to(pgsession, url_1)
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