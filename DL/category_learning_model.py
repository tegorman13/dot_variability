
import pandas as pd
import numpy as np
from sklearn.preprocessing import MinMaxScaler
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Input, Dense, Layer
from tensorflow.keras.optimizers import Adam
import tensorflow as tf

# Load the dataset
df = pd.read_csv('../dPattern24.csv')  # Update with the path to your dataset

# Normalize coordinates
coordinate_columns = [f'x{{i}}' for i in range(1, 10)] + [f'y{{i}}' for i in range(1, 10)]
scaler = MinMaxScaler(feature_range=(-1, 1))
df[coordinate_columns] = scaler.fit_transform(df[coordinate_columns])

# Assuming you have a function to identify test items and their corresponding category prototypes
# This will need to be adjusted based on your specific dataset and requirements
import numpy as np

def prepare_inputs(df):
    # Example: Assuming 'prototype' information is directly available or can be calculated
    # This also assumes you have a way to match test items with their corresponding category prototypes
    
    # Placeholder logic to identify test items - adjust based on your dataset
    test_items_df = df[df['Pattern_Token'].isin(['new_low', 'new_med', 'new_high'])]
    
    # Placeholder logic to calculate or retrieve prototypes for each subject and category
    # You might have a separate process or data for this
    prototypes_df = df[df['Pattern_Token'] == 'prototype']
    
    # Assuming prototypes_df contains the prototype for each category and subject
    # Organize data into a structure suitable for model input
    # This is highly dependent on how your data is structured and needs to be adapted
    
    # Initialize lists to hold the organized inputs
    test_items = []
    prototypes = []  # This will be a list of lists, each containing three prototypes' coordinates
    
    # Iterate through test items and find corresponding prototypes
    for index, row in test_items_df.iterrows():
        subject = row['sbjCode']
        category = row['Category']
        
        # Retrieve the coordinates for the test item
        test_item_coords = row[coordinate_columns].values
        
        # Retrieve prototypes for the subject (assuming one prototype per category)
        subject_prototypes = prototypes_df[prototypes_df['sbjCode'] == subject]
        
        # Placeholder: Retrieve or calculate the exact prototypes for the subject and category
        # You need to adapt this logic based on how your prototypes are defined or calculated
        proto_coords = [subject_prototypes[subject_prototypes['Category'] == c][coordinate_columns].values
                        for c in range(1, 4)]  # Assuming 3 categories
        
        # Check if we have found all necessary prototypes and the test item
        if len(proto_coords) == 3 and all(len(coords) > 0 for coords in proto_coords):
            test_items.append(test_item_coords)
            prototypes.append(np.concatenate(proto_coords))  # Flatten the prototype coordinates
            
    return np.array(test_items), np.array(prototypes)


test_items, prototypes = prepare_inputs(df)

class DistanceLayer(Layer):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

    def call(self, inputs):
        test_item, proto1, proto2, proto3 = inputs
        d1 = tf.norm(test_item - proto1, axis=1)
        d2 = tf.norm(test_item - proto2, axis=1)
        d3 = tf.norm(test_item - proto3, axis=1)
        distances = tf.stack([d1, d2, d3], axis=1)
        probabilities = tf.nn.softmax(-distances)
        return probabilities

def create_encoder():
    inputs = Input(shape=(18,))  # Adjust based on your input shape
    x = Dense(128, activation='relu')(inputs)
    x = Dense(64, activation='relu')(x)
    bottleneck = Dense(32, activation='relu')(x)
    return Model(inputs, bottleneck)

# Instantiate one encoder model to be shared
encoder = create_encoder()

# Define model with custom logic
test_item_input = Input(shape=(18,))
proto1_input = Input(shape=(18,))
proto2_input = Input(shape=(18,))
proto3_input = Input(shape=(18,))

test_item_encoded = encoder(test_item_input)
proto1_encoded = encoder(proto1_input)
proto2_encoded = encoder(proto2_input)
proto3_encoded = encoder(proto3_input)

predicted_category = DistanceLayer()([test_item_encoded, proto1_encoded, proto2_encoded, proto3_encoded])

model = Model(inputs=[test_item_input, proto1_input, proto2_input, proto3_input], outputs=predicted_category)
model.compile(optimizer='adam', loss='categorical_crossentropy')

# Placeholder for model training
# You'll need to adapt this part to fit your data structure
# model.fit(x=[test_items, proto1, proto2, proto3], y=labels, epochs=10, batch_size=32)

print("Model defined and ready for training. Remember to adjust data preparation and training call.")
