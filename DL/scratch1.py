import numpy as np

def euclidean_distance(point1, point2):
    """
    Calculate the Euclidean distance between two points.
    Points are provided as arrays or lists of coordinates.
    """
    point1, point2 = np.array(point1), np.array(point2)
    return np.sqrt(np.sum((point1 - point2) ** 2))

# Example usage
point1 = [0, 0, 0]
point2 = [3, 4, 5]
distance = euclidean_distance(point1, point2)
distance


# Extracting prototype patterns
prototypes = data[data['Pattern_Token'] == 'prototype']

# Preparing a function to calculate the distance from prototype for each novel item
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
    item_coords = item[['x1', 'y1', 'x2', 'y2', 'x3', 'y3', 'x4', 'y4', 'x5', 'y5', 'x6', 'y6', 'x7', 'y7', 'x8', 'y8', 'x9', 'y9']]
    prototype_coords = prototype.iloc[0][['x1', 'y1', 'x2', 'y2', 'x3', 'y3', 'x4', 'y4', 'x5', 'y5', 'x6', 'y6', 'x7', 'y7', 'x8', 'y8', 'x9', 'y9']]

    # Calculate Euclidean distance
    return euclidean_distance(item_coords, prototype_coords)

# Test the function with a sample novel item
sample_item = data[(data['Pattern_Token'] != 'prototype') & (data['Pattern_Token'] != 'old')].iloc[0]
distance_from_prototype = calculate_distance_from_prototype(sample_item, prototypes)
distance_from_prototype


def calculate_average_distance_from_training_items(item, training_items):
    """
    Calculate the average Euclidean distance of an item from all training items
    belonging to the same category and subject.
    """
    subject = item['sbjCode']
    category = item['Category']

    # Filter training items for this subject and category
    relevant_training_items = training_items[(training_items['sbjCode'] == subject) & (training_items['Category'] == category)]

    if relevant_training_items.empty:
        # In case there are no training items found (which should not happen), return NaN
        return np.nan

    # Extract coordinates for the item
    item_coords = item[['x1', 'y1', 'x2', 'y2', 'x3', 'y3', 'x4', 'y4', 'x5', 'y5', 'x6', 'y6', 'x7', 'y7', 'x8', 'y8', 'x9', 'y9']]

    # Calculate the average Euclidean distance
    distances = relevant_training_items.apply(lambda row: euclidean_distance(item_coords, row[['x1', 'y1', 'x2', 'y2', 'x3', 'y3', 'x4', 'y4', 'x5', 'y5', 'x6', 'y6', 'x7', 'y7', 'x8', 'y8', 'x9', 'y9']]), axis=1)
    return distances.mean()

# Extracting training items
training_items = data[data['Pattern_Token'] == 'old']

# Test the function with a sample novel item
distance_from_training_items = calculate_average_distance_from_training_items(sample_item, training_items)
distance_from_training_items


# Applying the distance calculation for the Prototype model to a subset
# Filtering novel items for the subset
novel_items_subset = data[(data['Pattern_Token'] != 'prototype') & (data['Pattern_Token'] != 'old')].head(50)

# Calculate distance from prototype for each novel item in the subset
novel_items_subset['distance_from_prototype'] = novel_items_subset.apply(lambda row: calculate_distance_from_prototype(row, prototypes), axis=1)

# Displaying the first few rows of the subset with the new feature
novel_items_subset[['sbjCode', 'Category', 'Pattern_Token', 'distance_from_prototype']].head()



# Calculate average distance from training items for each novel item in the subset
novel_items_subset['average_distance_from_training'] = novel_items_subset.apply(lambda row: calculate_average_distance_from_training_items(row, training_items), axis=1)

# Displaying the first few rows of the subset with the new feature for the Exemplar model
novel_items_subset[['sbjCode', 'Category', 'Pattern_Token', 'average_distance_from_training']].head()



# Filtering all novel items for the entire dataset
novel_items = data[(data['Pattern_Token'] != 'prototype') & (data['Pattern_Token'] != 'old')]

# Calculate distance from prototype for each novel item in the entire dataset
novel_items['distance_from_prototype'] = novel_items.apply(lambda row: calculate_distance_from_prototype(row, prototypes), axis=1)

# Displaying the first few rows of the dataset with the new feature for the Prototype model
novel_items[['sbjCode', 'Category', 'Pattern_Token', 'distance_from_prototype']].head()
