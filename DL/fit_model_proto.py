
import pandas as pd
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense
from tensorflow.keras.optimizers import Adam
from sklearn.model_selection import train_test_split
from scipy.spatial.distance import euclidean
import os

# Load dataset
file_path = 'dPattern24.csv'  # Replace with your dataset path
data = pd.read_csv(file_path)


def calculate_distance(item1, item2, metric='euclidean'):
    """
    Calculate distance between two items based on the specified metric.
    item1 and item2 are arrays or lists containing the coordinates of the dots.

    Parameters:
    item1 (list or array): Coordinates of the first item.
    item2 (list or array): Coordinates of the second item.
    metric (str): The metric to use for calculating distance ('euclidean' for now).

    Returns:
    float: Calculated distance.
    """
    if metric == 'euclidean':
        return euclidean(item1, item2)
    else:
        raise ValueError("Currently, only 'euclidean' metric is implemented.")

# Example usage with dummy coordinates
item1 = [0, 0, 1, 1, 2, 2]  # Example coordinates for one item
item2 = [1, 1, 2, 2, 3, 3]  # Example coordinates for another item

# Calculate Euclidean distance
distance_example = calculate_distance(item1, item2)
distance_example


# Extracting the prototypes from the dataset
prototypes = data[data['Pattern_Token'] == 'prototype']

def calculate_distance_from_prototype(item, prototypes):
    """
    Calculate the distance of an item from its prototype.
    The prototype is determined based on subject and category.
    """
    subject = item['sbjCode']
    category = item['Category']

    # Find the prototype for this subject and category
    prototype = prototypes[(prototypes['sbjCode'] == subject) & (prototypes['Category'] == category)]

    if prototype.empty:
        # In case there is no prototype found (which should not happen), return NaN
        return np.nan

    # Extract coordinates for the item and the prototype
    item_coords = item[['x1', 'y1', 'x2', 'y2', 'x3', 'y3', 'x4', 'y4', 'x5', 'y5', 'x6', 'y6', 'x7', 'y7', 'x8', 'y8', 'x9', 'y9']].values.flatten()
    prototype_coords = prototype.iloc[0][['x1', 'y1', 'x2', 'y2', 'x3', 'y3', 'x4', 'y4', 'x5', 'y5', 'x6', 'y6', 'x7', 'y7', 'x8', 'y8', 'x9', 'y9']].values.flatten()

    # Calculate Euclidean distance
    return calculate_distance(item_coords, prototype_coords)

# Testing the function with an example item from the dataset (an "old" token)
example_item = data[(data['Pattern_Token'] == 'old') & (data['sbjCode'] == 'sub399') & (data['Category'] == 1)].iloc[0]
distance_example = calculate_distance_from_prototype(example_item, prototypes)
distance_example


# Filtering data to include only "old" tokens
old_items = data[data['Pattern_Token'] == 'old']

# Function to calculate average distance for a given condition
def calculate_average_distance_for_condition(condition, old_items, prototypes):
    condition_items = old_items[old_items['condit'] == condition]
    distances = condition_items.apply(lambda item: calculate_distance_from_prototype(item, prototypes), axis=1)
    return distances.mean()

# Calculate average distances for each condition
conditions = ['low', 'medium', 'high', 'mixed']
average_distances = {condition: calculate_average_distance_for_condition(condition, old_items, prototypes) for condition in conditions}
average_distances

# {'low': 6.620641938685835,
#  'medium': 12.262503760277436,
#  'high': 17.974957623927263,
#  'mixed': 12.516961458380786}


# Filtering data to include only new items (new_low, new_med, new_high)
new_items = data[data['Pattern_Token'].isin(['new_low', 'new_med', 'new_high'])]

# Calculate distances from prototypes for new items
new_items['distance_from_prototype'] = new_items.apply(lambda item: calculate_distance_from_prototype(item, prototypes), axis=1)

# Prepare features and target variable
features = new_items[['distance_from_prototype']]
target = new_items['Corr']

# Splitting the data into training and testing sets
# It's important to stratify by subject to ensure subject-wise separation
train_features, test_features, train_target, test_target = train_test_split(features, target, test_size=0.2, stratify=new_items['sbjCode'])

# Showing the shape of the training and testing sets
train_features.shape, test_features.shape, train_target.shape, test_target.shape
# ((13132, 1), (3284, 1), (13132,), (3284,))

from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense
from tensorflow.keras.optimizers import Adam

def build_model():
    model = Sequential([
        Dense(64, activation='relu', input_shape=(1,)),  # Input layer with 64 neurons
        Dense(32, activation='relu'),  # Hidden layer with 32 neurons
        Dense(1, activation='sigmoid')  # Output layer for binary classification
    ])
    
    model.compile(optimizer=Adam(), loss='binary_crossentropy', metrics=['accuracy'])
    return model

model = build_model()

history = model.fit(train_features, train_target, epochs=10, validation_split=0.2)
test_loss, test_accuracy = model.evaluate(test_features, test_target)
print("Test Accuracy: ", test_accuracy)
print("Test Loss: ", test_loss)


model_save_path = 'DL/basic_model1.h5'  
model.save(model_save_path)
