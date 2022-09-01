## Load data
load("Desktop/Programming/Python-DataScience/data_hand_gest.RData")

## range of x
range(x)


## Standardize the data
x <- scale(x) # better standardizing the data
# merge target and input variables in a single dataframe
data0 <- data.frame(y = factor(y), x)

# this can be used to check if the data is balanced or not.
table(data0$y)

# for classification trees
library(rpart)
# set aside test data
N <- nrow(data0)
set.seed(202119)
test <- sample(1:N, N*0.2)
data_test <- data0[test,]

# select data for training and validation
train <- setdiff(1:N, test)
data <- data0[train,]
N_train <- nrow(data)

# we use this function to compute classification accuracy
class_acc <- function(y, yhat) {
  tab <- table(y, yhat)
  return( sum(diag(tab))/sum(tab) )
}


# for logistic regression we select only the last
# reading for each of the 8 sensors
set <- c(1, seq(9, 65, by = 8))
# just to identify the classifiers
classifiers <- c("class_tree_1", "class_tree_2", "log_reg_1", "log_reg_2")
K <- 5 # set number of folds
R <- 50 # set number of replicates --- NOTE : could be slow
out <- vector("list", R) # store accuracy output
# out is a list, each slot of this list will contain a matrix where each column
# corresponds to the accuracy of each classifier in the K folds


for ( r in 1:R ) {
  acc <- matrix(NA, K, 4) # accuracy of the classifiers in the K folds
  folds <- rep( 1:K, ceiling(N_train/K) )
  folds <- sample(folds) # random permute
  folds <- folds[1:N_train] # ensure we got N_train data points
  for ( k in 1:K ) {
    train_fold <- which(folds != k)
    validation <- setdiff(1:N_train, train_fold)
    # fit classifiers on the training data
    #
    # classification tree
    fit_ct_1 <- rpart(y ~ ., data = data, subset = train_fold, control = list(cp = 0.05))
    #
    fit_ct_2 <- rpart(y ~ ., data = data, subset = train_fold, control = list(cp = 0.1))
    #
    #
    # logistic regression
    fit_log_1 <- glm(y ~ ., data = data, family = "binomial", subset = train_fold)
    #
    fit_log_2 <- glm(y ~ ., data = data[,set], family = "binomial", subset = train_fold)
    # predict the classification of the test data observations in the dropped fold
    #
    # classification tree
    pred_ct_1 <- predict(fit_ct_1, type = "class", newdata = data[validation,])
    acc[k,1] <- class_acc(pred_ct_1, data$y[validation])
    #
    pred_ct_2 <- predict(fit_ct_2, type = "class", newdata = data[validation,])
    acc[k,2] <- class_acc(pred_ct_2, data$y[validation])
    #
    #
    # logistic regression
    pred_log_1 <- predict(fit_log_1, type = "response", newdata = data[validation,])
    pred_log_1 <- ifelse(pred_log_1 > 0.5, 1, 0)
    acc[k,3] <- class_acc(pred_log_1, data$y[validation])
    #
    pred_log_2 <- predict(fit_log_2, type = "response", newdata = data[validation,])
    pred_log_2 <- ifelse(pred_log_2 > 0.5, 1, 0)
    acc[k,4] <- class_acc(pred_log_2, data$y[validation])
  }
  out[[r]] <- acc
  # print(r) # print iteration number
}

# We can calculate the average fold accuracy for each one of the considered models in all replications.
avg <- t( sapply(out, colMeans) )

mean_acc <- colMeans(avg) # estimated mean accuracy
mean_acc

sd_acc <- apply(avg, 2, sd)/sqrt(R) # estimated mean accuracy standard deviation
sd_acc

# plot
mat <- data.frame( avg = c(avg), classifiers = rep(classifiers, each = R) )
boxplot(avg ~ classifiers, mat)


# fit model on full training data
fit_best <- rpart(y ~ ., data = data, control = list(cp = 0.05))

# predictive performance
pred_best <- predict(fit_best, type = "class", newdata = data_test)
class_acc(pred_best, data_test$y)

