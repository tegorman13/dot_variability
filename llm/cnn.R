
########


# Install and load the required packages
library(keras)
library(tensorflow)

# Set the directory path where the images are located
image_dir <- here("llm/all_pairs")

#paste0(here("llm/images/"), x, "_sm.png"

# Preprocess the data
pairCounts$pair_label <- as.character(pairCounts$pair_label)
pairCounts$mean_resp <- as.numeric(pairCounts$mean_resp)

# Create a list to store the image paths and ratings
image_data <- list()

# Iterate over each row in the dataframe
for (i in 1:nrow(pairCounts)) {
  pair_label <- pairCounts$pair_label[i]
  rating <- pairCounts$mean_resp[i]
  
  # Construct the image file path
  image_path <- file.path(image_dir, paste0(pair_label, "_sm.png"))
  
  # Read the image and preprocess it
  image <- image_load(image_path, target_size = c(224, 224))
  image <- image_to_array(image)
  image <- image / 255
  
  # Append the image path and rating to the list
  image_data[[i]] <- list(image = image, rating = rating)
}

# Unzip the image data into separate lists
images <- lapply(image_data, function(x) x$image)
ratings <- lapply(image_data, function(x) x$rating)

# Convert the lists to arrays
images <- array(unlist(images), dim = c(length(images), 224, 224, 3))
ratings <- unlist(ratings)

# Split the data into training and testing sets
train_indices <- sample(1:dim(images)[1], round(0.8 * dim(images)[1]))
train_images <- images[train_indices, , , ]
train_ratings <- ratings[train_indices]
test_images <- images[-train_indices, , , ]
test_ratings <- ratings[-train_indices]

# Define the model architecture
model <- keras_model_sequential()
model %>%
  layer_conv_2d(filters = 32, kernel_size = c(3, 3), activation = "relu", input_shape = c(224, 224, 3)) %>%
  layer_max_pooling_2d(pool_size = c(2, 2)) %>%
  layer_conv_2d(filters = 64, kernel_size = c(3, 3), activation = "relu") %>%
  layer_max_pooling_2d(pool_size = c(2, 2)) %>%
  layer_conv_2d(filters = 128, kernel_size = c(3, 3), activation = "relu") %>%
  layer_max_pooling_2d(pool_size = c(2, 2)) %>%
  layer_flatten() %>%
  layer_dense(units = 64, activation = "relu") %>%
  layer_dense(units = 1)

# Compile the model
model %>% compile(
  optimizer = "adam",
  loss = "mse",
  metrics = list("mae")
)

# Train the model
model %>% fit(
  train_images, train_ratings,
  epochs = 10,
  batch_size = 32,
  validation_data = list(test_images, test_ratings)
)

# Evaluate the model on the test set
model %>% evaluate(test_images, test_ratings)
# loss mae
# 1.50 0.98



# Make predictions on the test set
predictions <- model %>% predict(test_images)

# Combine the test ratings and predictions into a data frame
comparison_df <- data.frame(
  Human_Rating = test_ratings,
  Model_Prediction = as.vector(predictions)
)

# Print the comparison data frame
print(comparison_df)

# Calculate the mean squared error (MSE)
mse <- mean((comparison_df$Human_Rating - comparison_df$Model_Prediction)^2)
cat("Mean Squared Error (MSE):", mse, "\n")

# Calculate the root mean squared error (RMSE)
rmse <- sqrt(mse)
cat("Root Mean Squared Error (RMSE):", rmse, "\n")

# Calculate the mean absolute error (MAE)
mae <- mean(abs(comparison_df$Human_Rating - comparison_df$Model_Prediction))
cat("Mean Absolute Error (MAE):", mae, "\n")

# Create a scatter plot of human ratings vs. model predictions
library(ggplot2)
ggplot(comparison_df, aes(x = Human_Rating, y = Model_Prediction)) +
  geom_point() +
  geom_abline(intercept = 0, slope = 1, color = "red", linetype = "dashed") +
  xlab("Human Rating") +
  ylab("Model Prediction") +
  ggtitle("Human Ratings vs. Model Predictions")

# Create a histogram of the differences between human ratings and model predictions
ggplot(comparison_df, aes(x = Human_Rating - Model_Prediction)) +
  geom_histogram(binwidth = 0.5, fill = "blue", color = "black") +
  xlab("Difference (Human Rating - Model Prediction)") +
  ylab("Frequency") +
  ggtitle("Histogram of Differences")



library(reticulate)

#list.files(here("llm"), pattern="*.h5")
weights_path <- here("llm/vgg16_weights_tf_dim_ordering_tf_kernels_notop.h5")

base_model <- application_vgg16(
  weights = NULL,
  include_top = FALSE,
  input_shape = c(224, 224, 3)
)

# Load the pretrained weights from the local file
base_model %>% load_model_weights_hdf5(weights_path)

# Freeze the layers of the base model
base_model %>% freeze_weights()

# Create a new model on top of the base model
model <- keras_model_sequential() %>%
  base_model %>%
  layer_flatten() %>%
  layer_dense(units = 256, activation = "relu") %>%
  layer_dense(units = 1)

# Compile the model
model %>% compile(
  optimizer = "adam",
  loss = "mse",
  metrics = list("mae")
)

# Train the model
history <- model %>% fit(
  train_images, train_ratings,
  epochs = 10,
  batch_size = 32,
  validation_data = list(test_images, test_ratings)
)

# Evaluate the model on the test set
model %>% evaluate(test_images, test_ratings)
# loss  mae 
# 1.52 0.97 
