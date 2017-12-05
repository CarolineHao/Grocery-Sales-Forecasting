library(tidyverse)
library(broom)
library(glmnet)

load("../output/comb_testFeatures.RData")
load("../output/comb_validFeatures.RData")

train_x = comb_valid[,-c(1,3,4,5,6)]
train_y = comb_valid[,6]

train_x$linear_stack_pred = NA

test = comb_test[,c(1,7,6,8,9,10,11,12,13)]
test$linear_stack_pred = NA

lambdas <- 10^seq(3, -2, by = -.5)



unique_combos = unique(train_x$store_item_nbr)

for (i in 1:length(unique_combos)) {
  print(i)
  
  indices_train = which(train_x$store_item_nbr == unique_combos[i])
  x = train_x[indices_train,-c(1,2,3,9)]
  y = train_y[indices_train]
  
  indices_test = which(test$store_item_nbr.x == unique_combos[i])
  test_sub = test[indices_test,]
  test_x = test_sub[,c(5:9)]

  cv_fit <- cv.glmnet(model.matrix( ~ ., x), y, alpha = 0, lambda = lambdas)
  opt_lambda <- cv_fit$lambda.min
  fit <- cv_fit$glmnet.fit
  
  ytest_predicted <- predict(fit, s = opt_lambda, newx = model.matrix(~ . , test_x))
  ytrain_predicted <- predict(fit, s = opt_lambda, newx = model.matrix(~ . , x))
  
  train_x$linear_stack_pred[indices_train] = ytrain_predicted
  test$linear_stack_pred[indices_test] = ytest_predicted
  
}

w = ifelse(test$perishable == 0, 1, 1.25)

test$linear_stack_pred[test$linear_stack_pred < 0 | is.na(test$linear_stack_pred)] <- 0
test$unit_sales[test$unit_sales < 0] <- 0

sqrt(sum(w * (log(test$linear_stack_pred + 1) - log(test$unit_sales + 1))^2)/sum(w))


test$mean_pred = rowMeans(test[,c(5:9)])
sqrt(sum(w * (log(test$mean_pred + 1) - log(test$unit_sales + 1))^2)/sum(w))

save(train_x,test,file="../output/stack2_linear.RData")
