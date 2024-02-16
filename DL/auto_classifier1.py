from tensorflow.keras import Model, Input
from tensorflow.keras.layers import Dense, concatenate
from tensorflow.keras.optimizers import Adam

# Assuming normalized inputs
input_shape = (18,)  # 9 pairs of x,y coordinates

# Encoder
inputs = Input(shape=input_shape)
x = Dense(128, activation='relu')(inputs)
x = Dense(64, activation='relu')(x)
bottleneck = Dense(32, activation='relu')(x)  # Bottleneck representation

# Decoder
decoder_output = Dense(64, activation='relu')(bottleneck)
decoder_output = Dense(128, activation='relu')(decoder_output)
decoder_output = Dense(input_shape[0], activation='sigmoid')(decoder_output)  # Assuming normalization to [0, 1]

# Classifier
classifier_output = Dense(64, activation='relu')(bottleneck)
classifier_output = Dense(32, activation='relu')(classifier_output)
classifier_output = Dense(3, activation='softmax')(classifier_output)

# Model
model = Model(inputs=inputs, outputs=[decoder_output, classifier_output])

# Compile model
model.compile(optimizer=Adam(),
              loss=['mse', 'categorical_crossentropy'],
              metrics={'decoder_output': 'mse', 'classifier_output': 'accuracy'})

# Model summary
model.summary()


import pandas as pd

# Load the dataset
df = pd.read_csv('/mnt/data/dPattern24.csv')

# Display the first few rows of the dataframe to understand its structure
df.head()


from sklearn.model_selection import train_test_split
from sklearn.preprocessing import MinMaxScaler, OneHotEncoder
import numpy as np

# Normalize coordinates
coordinate_columns = [f'x{i}' for i in range(1, 10)] + [f'y{i}' for i in range(1, 10)]
scaler = MinMaxScaler(feature_range=(-1, 1))  # Normalize to range [-1, 1]
df[coordinate_columns] = scaler.fit_transform(df[coordinate_columns])

# Prepare inputs (flattened coordinates)
X = df[coordinate_columns].values

# Prepare outputs for the classifier - one-hot encode the 'Category'
encoder = OneHotEncoder(sparse=False)
Y_category = encoder.fit_transform(df[['Category']])

# Since it's a multi-task model, we have two outputs: the same inputs for the decoder and the category for the classifier
Y_decoder = X  # For reconstruction, the target is the same as the input
Y_classifier = Y_category

# Split the data into training and testing sets
X_train, X_test, Y_decoder_train, Y_decoder_test, Y_classifier_train, Y_classifier_test = train_test_split(
    X, Y_decoder, Y_category, test_size=0.2, random_state=42)

# Check the shapes of the prepared data
X_train.shape, X_test.shape, Y_decoder_train.shape, Y_decoder_test.shape, Y_classifier_train.shape, Y_classifier_test.shape
# ((20428, 18), (5108, 18), (20428, 18), (5108, 18), (20428, 3), (5108, 3))


from tensorflow.keras.models import Model
from tensorflow.keras.layers import Input, Dense, concatenate
from tensorflow.keras.optimizers import Adam

# Model architecture
input_layer = Input(shape=(18,))  # 18 inputs for the 9 x,y pairs

# Encoder
encoded = Dense(128, activation='relu')(input_layer)
encoded = Dense(64, activation='relu')(encoded)
bottleneck = Dense(32, activation='relu')(encoded)  # Bottleneck layer

# Decoder
decoded = Dense(64, activation='relu')(bottleneck)
decoded = Dense(128, activation='relu')(decoded)
decoded_output = Dense(18, activation='sigmoid')(decoded)  # Output layer for reconstruction

# Classifier
classifier = Dense(64, activation='relu')(bottleneck)
classifier = Dense(32, activation='relu')(classifier)
classifier_output = Dense(3, activation='softmax')(classifier)  # Output layer for classification

# Compile the model
model = Model(inputs=input_layer, outputs=[decoded_output, classifier_output])
model.compile(optimizer=Adam(learning_rate=0.001), 
              loss=['mse', 'categorical_crossentropy'], 
              metrics={'decoded_output': 'mse', 'classifier_output': 'accuracy'})

# Model summary
model.summary()

# Training the model
history = model.fit(X_train, [Y_decoder_train, Y_classifier_train],
                    validation_data=(X_test, [Y_decoder_test, Y_classifier_test]),
                    epochs=50,  # Start with a modest number of epochs; adjust based on performance and overfitting
                    batch_size=64,
                    verbose=1)

