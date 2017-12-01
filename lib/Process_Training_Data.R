library(forecast)
library(data.table)
library(dplyr)
library(lubridate)
library(doMC)
library(fpp)


train = fread("../Data/train.csv")
holidays = fread("../Data/holidays_events.csv")
oil = fread("../Data/oil.csv")
holidays$date <- as.Date(parse_date_time(holidays$date,'%y-%m-%d'))
oil$date <- as.Date(parse_date_time(oil$date,'%y-%m-%d'))

train$date <- as.Date(parse_date_time(train$date,'%y-%m-%d'))
train$store_item_nbr <- paste(train$store_nbr, train$item_nbr, sep="_")
train$unit_sales <- as.numeric(train$unit_sales)
train$unit_sales[train$unit_sales < 0] <- 0

train_sub <- train[date >= as.Date("2017-04-01"), ]
train_sub$date = as.Date(train_sub$date)

train_sub <- train_sub %>% 
  mutate(year = year(ymd(date)))  %>%
  mutate(month = month(ymd(date)))  %>%
  mutate(dayOfWeek = wday(date))  %>%
  mutate(day = day(ymd(date))) 

HolidaysNational = holidays %>%
  filter(type != "Work Day") %>%
  filter(locale == "National")

comb = left_join(train_sub,oil)
comb = left_join(comb,HolidaysNational,by='date')

write.csv(comb,"../Data/train_sub.csv")
