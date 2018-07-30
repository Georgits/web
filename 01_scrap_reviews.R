# General-purpose data wrangling
library(tidyverse)  

# Parsing of HTML/XML files  
library(rvest)    

# String manipulation
library(stringr)   

# Verbose regular expressions
library(rebus)     

# Eases DateTime manipulation
library(lubridate)

# url <-'http://www.trustpilot.com/review/www.amazon.com'
url <-'https://www.trustpilot.com/review/dealstruck.com'

# Functions

### 1. Finde heraus, wie viele Seiten mit reviews gibt es ----
get_last_page <- function(html){
  
  pages_data <- html %>% 
    # The '.' indicates the class
    html_nodes('.pagination-page') %>% 
    # Extract the raw text as a list
    html_text()                   
  
  # The second to last of the buttons is the one
  pages_data[(length(pages_data)-1)] %>%            
    # Take the raw string
    unname() %>%                                     
    # Convert to number
    as.numeric()                                     
}

first_page <- read_html(url)
(latest_page_number <- get_last_page(first_page))

# erstelle Liste der Pages, die abgerufen werden sollen
list_of_pages <- str_c(url, '?page=', 1:latest_page_number)


### 2. Ziehe die reviews raus ----
get_reviews <- function(html){
  html %>% 
    # The relevant tag
    html_nodes('.review-info__body__text') %>%      
    html_text() %>% 
    # Trim additional white space
    str_trim() %>%                       
    # Convert the list into a vector
    unlist()                             
}

### 3. Ziehe die Namen der Reviewer raus ----
get_reviewer_names <- function(html){
  html %>% 
    html_nodes('.consumer-info__details__name') %>% 
    html_text() %>% 
    str_trim() %>% 
    unlist()
}

### 4. Ziehe die Datumsangaben raus ----
get_review_dates <- function(html){
  
  status <- html %>% 
    html_nodes('time') %>% 
    # The status information is this time a tag attribute
    html_attrs() %>%             
    # Extract the second element
    map(2) %>%                    
    unlist() 
  
  dates <- html %>% 
    html_nodes('time') %>% 
    html_attrs() %>% 
    map(1) %>% 
    # Parse the string into a datetime object with lubridate
    ymd_hms() %>%                 
    unlist()
  
  # Combine the status and the date information to filter one via the other
  return_dates <- tibble(status = status, dates = dates) %>%   
    # Only these are actual reviews
    filter(status == 'ndate') %>%              
    # Select and convert to vector
    pull(dates) %>%                            
    # Convert DateTimes to POSIX objects
    as.POSIXct(origin = '1970-01-01 00:00:00') 
  
  # The lengths still occasionally do not lign up. You then arbitrarily crop the dates to fit
  # This can cause data imperfections, however reviews on one page are generally close in time)
  
  length_reviews <- length(get_reviews(html))
  
  return_reviews <- if (length(return_dates)> length_reviews){
    return_dates[1:length_reviews]
  } else{
    return_dates
  }
  return_reviews
}

### 5. Ziehe die Ratings raus ----
get_star_rating <- function(html){
  
  # The pattern you look for: the first digit after `count-`
  pattern = 'star-rating-'%R% capture(DIGIT)    
  
  ratings <-  html %>% 
    html_nodes('.star-rating') %>% 
    html_attrs() %>% 
    # Apply the pattern match to all attributes
    map(str_match, pattern = pattern) %>%
    # str_match[1] is the fully matched string, the second entry
    # is the part you extract with the capture in your pattern  
    map(2) %>%                             
    
    unlist()
  
  # Leave out the first 2 instance, as it is not part of a review
  ratings[3:length(ratings)]               
}





### 6. Mache eine Tabelle aus gezogenen daten----
get_data_table <- function(html, company_name){
  
  # Extract the Basic information from the HTML
  reviews <- get_reviews(html)
  reviewer_names <- get_reviewer_names(html)
  dates <- get_review_dates(html)
  ratings <- get_star_rating(html)
  
  # Combine into a tibble
  combined_data <- tibble(reviewer = reviewer_names,
                          date = dates,
                          rating = ratings,
                          review = reviews) 
  
  # Tag the individual data with the company name
  combined_data %>% 
    mutate(company = company_name) %>% 
    select(company, reviewer, date, rating, review)
}



get_data_from_url <- function(url, company_name){
  html <- read_html(url)
  get_data_table(html, company_name)
}



### 7. Alles in allem ----
scrape_write_table <- function(url, company_name){
  
  # Read first page
  first_page <- read_html(url)
  
  # Extract the number of pages that have to be queried
  latest_page_number <- get_last_page(first_page)
  
  # Generate the target URLs
  list_of_pages <- str_c(url, '?page=', 1:latest_page_number)
  
  # Apply the extraction and bind the individual results back into one table, 
  # which is then written as a tsv file into the working directory
  list_of_pages %>% 
    # Apply to all URLs
    map(get_data_from_url, company_name) %>%  
    # Combine the tibbles into one tibble
    bind_rows() %>%                           
    # Write a tab-separated file
    write_tsv(str_c(company_name,'.tsv'))     
}



### 8. Führe aus ----
scrape_write_table(url, 'amazon')
amz_tbl <- read_tsv('amazon.tsv')
tail(amz_tbl, 5)

scrape_write_table(url, 'Dealstruck')
dealstruck_tbl <- read_tsv('Dealstruck.tsv')
head(dealstruck_tbl, 5)

