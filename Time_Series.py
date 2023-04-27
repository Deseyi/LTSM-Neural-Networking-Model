# -*- coding: utf-8 -*-
"""
Created on Mon Apr 24 21:51:40 2023

@author: desey
"""

import pandas as pd
import os
import numpy as np
from sklearn.model_selection import train_test_split
from keras.models import Sequential
from keras.layers import LSTM, Dense
from sklearn.preprocessing import MinMaxScaler

# Setting working directory
path = 'C:/Users/desey/Documents/MACHINE_LEARN'
os.chdir(path)

# Load the CSV file into a pandas DataFrame
df = pd.read_csv('J_17.csv')

# Print the first few rows of the DataFrame to check that the data was loaded correctly
print(df.head())

# Split the data into training, validation, and testing sets
#train, test = train_test_split(df, test_size=0.2, random_state=42)
#train, val = train_test_split(train, test_size=0.25, random_state=42)

# Print the number of rows in each dataset
#print(f'Training data: {len(train)} rows')
#print(f'Validation data: {len(val)} rows')
#print(f'Testing data: {len(test)} rows')

# Convert the data to a numpy array
data = df['WaterLevelElevation'].values.reshape(-1, 1)

# Scale the data to a range of 0 to 1
scaler = MinMaxScaler(feature_range=(0, 1))
scaled_data = scaler.fit_transform(data)

# Define the number of time steps to use for each input
lookback = 50

# Create the input and output datasets
X = []
y = []
for i in range(lookback, len(scaled_data)):
    X.append(scaled_data[i-lookback:i, 0])
    y.append(scaled_data[i, 0])
X = np.array(X)
y = np.array(y)

# Split the data into training and testing sets
split = int(0.8 * len(X))
X_train, y_train = X[:split], y[:split]
splitv = int(0.3 * len(X_train))
X_val, y_val = X_train[:splitv], y[:splitv]
X_test, y_test = X[split:], y[split:]

# Reshape the input data to match the LSTM input shape
X_train = np.reshape(X_train, (X_train.shape[0], X_train.shape[1], 1))
X_val = np.reshape(X_val, (X_val.shape[0], X_val.shape[1], 1))
X_test = np.reshape(X_test, (X_test.shape[0], X_test.shape[1], 1))

# Define the LSTM model
model = Sequential()
model.add(LSTM(50, input_shape=(lookback, 1)))
model.add(Dense(1))
model.compile(loss='mse', optimizer='adam')

# Train the model
model.fit(X_train, y_train, epochs=10, batch_size=32, validation_data=(X_val, y_val))

# Make predictions on the test data
y_pred = model.predict(X_test)

# Inverse scale the predictions and actual values
y_pred = scaler.inverse_transform(y_pred)
y_test = scaler.inverse_transform(y_test.reshape(-1, 1))

# Calculate the root mean squared error (RMSE) of the predictions
rmse = np.sqrt(np.mean((y_pred - y_test) ** 2))
print(f'RMSE: {rmse:.2f}')


import matplotlib.pyplot as plt



# Create a scatter plot of the predicted vs test values
#plt.scatter(y_pred, y_test)

# Add axis labels and a title to the plot
#plt.xlabel('Predicted Values')
#plt.ylabel('Test Values')
#plt.title('Predicted vs Test Values')

# Add a diagonal line to represent perfect predictions
#min_value = np.min(np.concatenate((y_pred, y_test)))
#max_value = np.max(np.concatenate((y_pred, y_test)))
#plt.plot([min_value, max_value], [min_value, max_value], 'r--')

plt.plot(y_pred, label= 'predicted')
plt.plot(y_test, label= 'test')
