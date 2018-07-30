# For working with time series
library(xts)      

# For hypothesis testing
library(infer)
library(dplyr)
library(readr)

data_company_a <- read_tsv('amazon.tsv')
data_company_b <- read_tsv('Dealstruck.tsv')


full_data <- rbind(data_company_a, data_company_b)

full_data%>%
  group_by(company) %>% 
  summarise(count = n(), mean_rating = mean(rating))


company_a_ts <- xts(data_company_a$rating, data_company_a$date)
colnames(company_a_ts) <- 'rating'
company_b_ts <- xts(data_company_b$rating, data_company_b$date)
colnames(company_b_ts) <- 'rating'

open_ended_interval <- '2016-01-01/'

# Subsetting the time series
company_a_sts <- company_a_ts[open_ended_interval] 
company_b_sts <- company_b_ts[open_ended_interval]


company_a_month_avg <-  apply.monthly(company_a_sts, colMeans, na.rm = T)
company_a_month_count  <-  apply.monthly(company_a_sts, FUN = length)

company_b_month_avg <-  apply.monthly(company_b_sts, colMeans, na.rm = T)
company_b_month_count  <-  apply.monthly(company_b_sts, FUN = length)


full_data <- full_data %>%  
  filter(date >= start_date) %>% 
  mutate(weekday = weekdays(date, abbreviate = T),
         hour = hour(date))

# Treat the weekdays as factor. 
# The order is for the plotting only
full_data$weekday <-  factor(full_data$weekday, 
                             levels = c('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'))