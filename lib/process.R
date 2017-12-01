---
title: "process"
author: "Shiqi Duan"
date: "2017/12/1"
output: html_document
---
  
#packages
library(data.table)
library(lubridate)
library(date)
library(dplyr)

setwd("/Users/duanshiqi/Documents/GitHub/fall2017-project5-group1/")
train <- fread("./data/train.csv")
subtrain <- train[train$date < "2016-08-16"&train$date>="2014-08-15",]
subtest <- train[train$date > "2016-08-15",]
rm(train)

# chose top 10 stores and top 200 items with respect to observations
store_tbl <- table(subtrain$store_nbr)
store_max <- store_tbl[order(store_tbl, decreasing = T)][1:10]
item_tbl <- table(subtrain$item_nbr)
item_max <- item_tbl[order(item_tbl, decreasing = T)][1:200]

store_test <- subtest$store_nbr[subtest$store_nbr %in% names(store_max)]
item_test <- subtest$item_nbr[subtest$item_nbr %in% names(item_max)]
store_test_perfm <- table(store_test)
item_test_perfm <- table(item_test)

subtrain1 <- subtrain[subtrain$store_nbr %in% names(store_max) & subtrain$item_nbr %in% names(item_max),]
rm(subtrain)
subtest1 <- subtest[subtest$store_nbr %in% names(store_max) & subtest$item_nbr %in% names(item_max),]
rm(subtest)

subtrain1$date <- as.Date(parse_date_time(subtrain1$date,'%y-%m-%d'))
subtrain1$store_item_nbr <- paste(subtrain1$store_nbr, subtrain1$item_nbr, sep="_")
subtest1$date <- as.Date(parse_date_time(subtest1$date, '%y-%m-%d'))
subtest1$store_item_nbr <- paste(subtest1$store_nbr, subtest1$item_nbr, sep="_")

write.csv(subtrain1,"./data/our_train.csv")
write.csv(subtest1, "./data/our_test.csv")

# combine with other useful variables
items<-read.csv("./data/original data/items.csv",header=TRUE)
holidays <- read.csv("./data/original data/holidays_events.csv",header = TRUE)
oil <- read.csv("./data/original data/oil.csv",header=TRUE)

train_sub <- subtrain1 %>% 
  mutate(year = year(ymd(date)))  %>%
  mutate(month = month(ymd(date)))  %>%
  mutate(dayOfWeek = wday(date))  %>%
  mutate(day = day(ymd(date)))
train_sub1 <- merge(train_sub, items, by.x = "item_nbr", by.y = "item_nbr")

holidaysNational = holidays %>%
  filter(type != "Work Day") %>%
  filter(locale == "National")
holidaysNational <- holidaysNational%>%select(date,type,transferred)
holidaysNational$celebrated <- ifelse(holidaysNational$transferred == "True", FALSE, TRUE)
holidaysNational$date <- as.Date(parse_date_time(holidaysNational$date,'%y-%m-%d'))
comb = left_join(train_sub1,holidaysNational,by='date')

oil$date <- as.Date(parse_date_time(oil$date,'%y-%m-%d'))
comb <- left_join(comb, oil, by='date')

write.csv(comb,"./output/combined_train.csv")

test_sub <- subtest1 %>% 
  mutate(year = year(ymd(date)))  %>%
  mutate(month = month(ymd(date)))  %>%
  mutate(dayOfWeek = wday(date))  %>%
  mutate(day = day(ymd(date)))
test_sub1 <- merge(test_sub, items, by.x = "item_nbr", by.y = "item_nbr")

comb1 = left_join(test_sub1,holidaysNational,by='date')
comb1 <- left_join(comb1, oil, by='date')

write.csv(comb1,"./output/combined_test.csv")
