# start script
Sys.unsetenv("RETICULATE_PYTHON")
system("unset RETICULATE_PYTHON")
reticulate::use_python("/Users/thomasgorman/miniconda3/bin/python", required = TRUE)
## Load necessary libraries
library(tidyverse)  # For data manipulation
library(caret)      # For data preprocessing
library(keras)      # For building the neural network model

# reticulate::py_config()
use_python("/Users/thomasgorman/miniconda3/bin/python", required = TRUE)


## Data Preprocessing

# Load the dataset
df <- read.csv("dPattern24.csv")  # Update with the path to your dataset

# Normalize coordinates
coordinate_columns <- c(paste0("x", 1:9), paste0("y", 1:9))
preProcValues <- preProcess(df[, coordinate_columns], method = c("center", "scale"))
df[, coordinate_columns] <- predict(preProcValues, df[, coordinate_columns])

# Prepare inputs and outputs
X <- as.matrix(df[, coordinate_columns])

# Convert categories to one-hot encoded format
Y_category <- to_categorical(as.numeric(df$Category))

# Split the data
set.seed(42)
trainIndex <- createDataPartition(df$Category, p = .8, 
                                  list = FALSE, 
                                  times = 1)
X_train <- X[trainIndex, ]
X_test <- X[-trainIndex, ]
Y_category_train <- Y_category[trainIndex, ]
Y_category_test <- Y_category[-trainIndex, ]

## Model Definition

# Define the multi-task model
inputs <- layer_input(shape = 18)  # 9 pairs of x,y coordinates
x <- inputs %>%
  layer_dense(units = 128, activation = "relu") %>%
  layer_dense(units = 64, activation = "relu")
bottleneck <- layer_dense(units = 32, activation = "relu")(x)

# Decoder
decoder_output <- bottleneck %>%
  layer_dense(units = 64, activation = "relu") %>%
  layer_dense(units = 128, activation = "relu") %>%
  layer_dense(units = 18, activation = "sigmoid")

# Classifier
classifier_output <- bottleneck %>%
  layer_dense(units = 64, activation = "relu") %>%
  layer_dense(units = 32, activation = "relu") %>%
  layer_dense(units = 3, activation = "softmax")

model <- keras_model(inputs = inputs, outputs = list(decoder_output, classifier_output))

# Compile model
model %>% compile(
  optimizer = "adam",
  loss = list("mean_squared_error", "categorical_crossentropy"),
  metrics = list(NULL, "accuracy")
)

summary(model)

## Model Training
history <- model %>% fit(
  x = X_train, 
  y = list(X_train, Y_category_train),
  validation_data = list(X_test, list(X_test, Y_category_test)),
  epochs = 50, 
  batch_size = 64
)

## Evaluation
eval_result <- model %>% evaluate(X_test, list(X_test, Y_category_test))
cat("Test Loss:", eval_result[[1]], "Test Accuracy:", eval_result[[2]], "\n")
