# classifying_hand_gestures
We consider the problem of classifying hand gestures by means of muscle activity recorded via electromyography
(EMG), a technique which measures the electrical activity produced by muscles beneath by means of sensors on the
skin. The task is to predict the type of gesture given the input EMG sensor data. The dataset data_hand_gest.RData contains EMG (electromyography) measurements for two types of gestures: hand closed in a fist (class 0) and open hand (class 1)

## Cross-validation 
Cross-validation could also be used to select the best classifier. Indeed, K-fold cross-validation can be used to check
which model proves better at predicting the validation data points in the dropped folds. We introduced how to split the data into training, 
validation and test sets in order to select the best classifier among a collection of competitors and evaluate its accuracy at predicting the classification of new data points.

