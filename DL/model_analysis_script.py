
import pandas as pd
from tensorflow.keras.models import load_model
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.spatial.distance import euclidean
from sklearn.model_selection import train_test_split

model = load_model("DL/basic_model1.h5")
data = pd.read_csv('dPattern24.csv')



def calculate_distance(item1, item2, metric='euclidean'):
    if metric == 'euclidean':
        return euclidean(item1, item2)
    else:
        raise ValueError("Currently, only 'euclidean' metric is implemented.")


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


# test_loss, test_accuracy = model.evaluate(test_features, test_target)
# print("Test Accuracy: ", test_accuracy)

predictions = model.predict(test_features)

# Merge additional information back into the DataFrame
test_data_with_predictions = test_features.copy()
test_data_with_predictions['predicted_corr'] = predictions
test_data_with_predictions['actual_corr'] = test_target

# Merging with the original data to get 'sbjCode', 'condit', and 'distortion'
test_data_with_predictions = test_data_with_predictions.merge(data[['sbjCode', 'condit', 'distortion']], left_index=True, right_index=True, how='left')


# Overall comparison
# overall_comparison = test_data_with_predictions.groupby('sbjCode').agg({'predicted_corr':'mean', 'actual_corr':'mean'}).reset_index()
# print("Overall Comparison:\n", overall_comparison.head(20))


# Correcting the groupby method by passing the column names as a list
overall_comparison = test_data_with_predictions.groupby(['sbjCode', 'condit', 'distortion']).agg({'predicted_corr':'mean', 'actual_corr':'mean'}).reset_index()
print("Overall Comparison:\n", overall_comparison.head(40))

# Detailed comparison
detailed_comparison = test_data_with_predictions.groupby(['condit', 'distortion']).agg({'predicted_corr':'mean', 'actual_corr':'mean'}).reset_index()
print("Detailed Comparison by Condition and Distortion:\n", detailed_comparison.head(5))






plt.figure(figsize=(20, 10))
sns.boxplot(x='condit', y='predicted_corr', hue='distortion', data=overall_comparison)
sns.boxplot(x='condit', y='actual_corr', hue='distortion', data=overall_comparison, dodge=True)
plt.title('Distribution of Predicted vs Actual Correlation by Condition and Distortion')
plt.show()


import seaborn as sns
import matplotlib.pyplot as plt

# Scatter plot color-coded by distortion
plt.figure(figsize=(10, 6))
sns.scatterplot(data=overall_comparison, x='predicted_corr', y='actual_corr', hue='distortion', style='condit')
plt.title('Predicted vs Actual Correlations by Distortion Level')
plt.xlabel('Predicted Correlation')
plt.ylabel('Actual Correlation')
plt.legend(title='Distortion', bbox_to_anchor=(1.05, 1), loc='upper left')
plt.tight_layout()
plt.show()

# Pairplot with hue set to 'condit'
sns.pairplot(data=overall_comparison, hue='condit', vars=['predicted_corr', 'actual_corr'])
plt.show()

# Boxplot for each condit and distortion
plt.figure(figsize=(14, 7))
sns.boxplot(data=overall_comparison, x='condit', y='predicted_corr', hue='distortion')
plt.title('Distribution of Predicted Correlations for Each Condit and Distortion')
plt.xlabel('Condition')
plt.ylabel('Predicted Correlation')
plt.legend(title='Distortion', bbox_to_anchor=(1.05, 1), loc='upper left')
plt.tight_layout()
plt.show()

# Lineplot for mean predicted_corr and actual_corr across distortion levels within each condit
plt.figure(figsize=(14, 7))
sns.lineplot(data=overall_comparison, x='distortion', y='predicted_corr', hue='condit', marker='o')
sns.lineplot(data=overall_comparison, x='distortion', y='actual_corr', hue='condit', marker='o', linestyle='--')
plt.title('Mean Predicted and Actual Correlations by Distortion Level and Condit')
plt.xlabel('Distortion')
plt.ylabel('Mean Correlation')
plt.legend(title='Condit', bbox_to_anchor=(1.05, 1), loc='upper left')
plt.tight_layout()
plt.show()




# # Scatter plot for overall comparison
# plt.figure(figsize=(10, 6))
# sns.scatterplot(data=overall_comparison, x='predicted_corr', y='actual_corr')
# plt.xlabel('Predicted Accuracy')
# plt.ylabel('Actual Accuracy')
# # color by level of distortion
# sns.scatterplot(data=overall_comparison, x='predicted_corr', y='actual_corr', hue='distortion')
# plt.title('Model Predictions vs. Actual Performance - Overall')
# plt.show()



# # Bar plot for detailed comparison
# plt.figure(figsize=(12, 8))
# sns.barplot(x='condit', y='predicted_corr', hue='distortion', data=detailed_comparison)
# plt.xlabel('Condition')
# plt.ylabel('Predicted Accuracy')
# plt.title('Predicted Accuracy by Condition and Distortion Level')
# plt.legend(title='Distortion Level')
# plt.show()