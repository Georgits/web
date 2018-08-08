library(jsonlite)
library(rvest)
library(pbapply)
library(data.table)

json.cities<-paste0('http://h1bdata.info/cities.php?term=', letters)
all.cities<-unlist(pblapply(json.cities,fromJSON))

city.year<-expand.grid(city=all.cities,yr=seq(2012,2018))

city.year$city<-urltools::url_encode(as.character(city.year$city))

all.urls<-paste0('http://h1bdata.info/index.php?em=&job=&city=', city.year[,1],'&year=', city.year[,2])


main<-function(url.x){
  x<-read_html(url.x)
  x<-html_table(x)
  x<-data.table(x[[1]])
  return(x)
  Sys.sleep(5)
}


all.h1b<-pblapply(all.urls, main)


all.h1b<-rbindlist(all.h1b)


write.csv(all.h1b,'h1b_data.csv', row.names=F)


# Cleaning Your Data
library(ggplot2)
library(ggthemes)
library(lubridate)
library(stringr)
options(scipen=999)

h1b.data<-fread('h1b_data.csv')


colnames(h1b.data)<-tolower(names(h1b.data))
colnames(h1b.data)<-gsub(' ', '_', names(h1b.data))

tail(h1b.data, 8)

apply(h1b.data,2,class)

# format submit_date
tail(h1b.data$submit_date)
h1b.data$submit_date<-gsub('/', '-', h1b.data$submit_date)

h1b.data$submit_date<-mdy(h1b.data$submit_date)
tail(h1b.data$submit_date)
class(h1b.data$submit_date)


# format start_date
tail(h1b.data$start_date)
h1b.data$start_date<-gsub('/', '-', h1b.data$start_date)

h1b.data$start_date<-mdy(h1b.data$start_date)
tail(h1b.data$start_date)
class(h1b.data$start_date)

# extract month and year information
h1b.data$submit_month<-month(h1b.data$submit_date)
h1b.data$submit_yr<-year(h1b.data$submit_date)
head(h1b.data)

# formt base_salary
h1b.data$base_salary<-gsub(',','',h1b.data$base_salary)
h1b.data$base_salary<-as.numeric(h1b.data$base_salary)
head(h1b.data$base_salary)

# split city and state information
state<-str_split_fixed(h1b.data$location,', ', 2)
h1b.data$city<-state[,1]
h1b.data$state<-state[,2]



# Exploring Your Data
state.tally<-table(h1b.data$state)
state.tally<-data.frame(state=names(state.tally), h1b=as.vector(state.tally))


barplot(state.tally$h1b,
        names.arg = names(table(h1b.data$state)),
        las=3)


head(state.x77)


state.data<-data.frame(state=state.abb,state.x77)
state.data<-merge(state.tally,
                  state.data,
                  by='state')
state.data[15:20,]


cor(state.data$Population, state.data$h1b)


pairs(~ h1b + Population + Income,
      data = state.data,
      main='h1b relationships')

plot(state.data$Income,state.data$h1b,
     main = 'Income to H1B')


ggplot(h1b.data) +
  geom_boxplot(aes(factor(case_status),base_salary,fill=as.factor(case_status))) +
  ylim(0,100000) +
  theme_gdocs() +
  scale_fill_gdocs() +
  theme(axis.text.x=element_blank())