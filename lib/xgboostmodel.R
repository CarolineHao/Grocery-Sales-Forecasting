library(xgboost)
library(readr)

eval <- function(preds, Xtest){
  weights <- ifelse(Xtest$perishable == 0, 1, 1.25)
  num <- sum(weights*(preds - Xtest$log_sales)^2)
  dem <- sum(weights)
  return((num/dem)**0.5)
}

combined_train <- read_csv("ADS/fall2017-project5-group1/data/combined_train.csv")
combined_test <- read_csv("ADS/fall2017-project5-group1/data/subtrain.csv")
combined_valid <- read_csv("ADS/fall2017-project5-group1/data/validation.csv")

df_format <- function(df){
  df <- df[!is.na(df$unit_sales),]
  df$onpromotion[df$onpromotion == FALSE] <- 0
  df$onpromotion[df$onpromotion == TRUE] <- 1

  df$unit_sales[df$unit_sales < 0] <- 0
  df$log_sales <- log(df$unit_sales + 1)
return(df)
}

combined_train <- df_format(combined_train)
combined_test <- df_format(combined_test)
combined_valid <- df_format(combined_valid)

features <- c('item_nbr', 'id', 'store_nbr', 'onpromotion', 'year', 'month', 'dayOfWeek', 'class', 'perishable', 'dcoilwtico')

dtrain <- xgb.DMatrix(data = as.matrix(combined_train[, features]), label = combined_train$log_sales)
dtest <- xgb.DMatrix(data = as.matrix(combined_test[, features]), label = combined_test$log_sales)
dvalid <- xgb.DMatrix(data = as.matrix(combined_valid[, features]), label = combined_valid$log_sales)

watchlist <- list(train=dtrain, test = dtest)

params <- list(max_depth = 6)

bst <- xgb.train(data=dtrain, max_depth=8, eta=1, nrounds=20, watchlist=watchlist,
                 nthread = 4, objective = "reg:linear")

features_test <- predict(bst, dtest)

eval(features_test, combined_test)

saveRDS(features_test, "features_test.rds")

features_valid <- predict(bst, dvalid)

eval(features_valid, combined_valid)

saveRDS(features_valid, "features_valid.rds")

