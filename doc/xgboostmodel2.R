library(xgboost)
library(readr)
library(caret)
library(doMC)
library(mlr)
registerDoMC(cores=4)

set.seed(6)

eval <- function(preds, Xtest){
  weights <- ifelse(Xtest$perishable == 0, 1, 1.25)
  num <- sum(weights*(preds - Xtest$log_sales)^2)
  dem <- sum(weights)
  return((num/dem)**0.5)
}

combined_train <- read_csv("../data/combined_train.csv")
combined_test <- read_csv("../output/combined_test.csv")
combined_valid <- read_csv("../data/validation.csv")

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

searchGridSubCol <- expand.grid(subsample = c(0.7), 
                                colsample_bytree = c(0.7),
                                max_depth = c(8),
                                min_child = c(1, 5, 10), 
                                eta = c(0.7),
                                gamma = c(0.1, 1, 10)
)

ntrees <- 40

system.time(
  rmseErrorsHyperparameters <- apply(searchGridSubCol, 1, function(parameterList){
    
    #Extract Parameters to test
    currentGamma <- parameterList[["gamma"]]
    currentSubsampleRate <- parameterList[["subsample"]]
    currentColsampleRate <- parameterList[["colsample_bytree"]]
    currentDepth <- parameterList[["max_depth"]]
    currentEta <- parameterList[["eta"]]
    currentMinChild <- parameterList[["min_child"]]
    
    xgboostModelCV <- xgb.cv(data =  dtrain, nrounds = ntrees, nfold = 2, showsd = TRUE, 
                             metrics = "rmse", verbose = TRUE, "eval_metric" = "rmse",
                             "objective" = "reg:linear", "max.depth" = currentDepth, "eta" = currentEta,                               
                             "subsample" = currentSubsampleRate, "colsample_bytree" = currentColsampleRate
                             , print_every_n = 10, "min_child_weight" = currentMinChild, "gamma" = currentGamma,
                             booster = "gbtree",
                             early_stopping_rounds = 10)
    
    xvalidationScores <- as.data.frame(xgboostModelCV$evaluation_log)
    rmse <- tail(xvalidationScores$test_rmse_mean, 1)
    trmse <- tail(xvalidationScores$train_rmse_mean,1)
    output <- return(c(rmse, trmse, currentSubsampleRate, currentColsampleRate, currentDepth, currentEta, currentMinChild, currentGamma))
    
  }))

output <- as.data.frame(t(rmseErrorsHyperparameters))
varnames <- c("TestRMSE", "TrainRMSE", "SubSampRate", "ColSampRate", "Depth", "eta", "currentMinChild", "Gammma")
names(output) <- varnames

save(output, file = "../output/cverror.RData")

bst <- xgb.train(data=dtrain, eta=0.7, gamma = 1, max_depth = 8,
              min_child_weight = 10, subsample = 0.7, colsample_bytree = 0.7,
              nrounds=40, watchlist=watchlist, nthread = 4, objective = "reg:linear")


features_test <- predict(bst, dtest)

eval(features_test, combined_test)

save(features_test, file = "../output/features_test.RData")

features_valid <- predict(bst, dvalid)

eval(features_valid, combined_valid)

save(features_valid, file = "../output/features_valid.RData")
