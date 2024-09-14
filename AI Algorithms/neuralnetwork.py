import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.neural_network import MLPRegressor
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import mean_squared_error
import matplotlib.pyplot as plt
from sampledata import generate_sample_data

from sklearn.ensemble import VotingRegressor


df = pd.read_json("/Users/niambashambu/Desktop/AI-RUNNING-APP/activities.json")

# Filter for runs
df_runs = df[df['type'] == 'Run'].copy()
df_runs['distance_km'] = df_runs['distance'] / 1000
df_runs['moving_time_min'] = df_runs['moving_time'] / 60
df_runs['pace_min_per_km'] = df_runs['moving_time_min'] / df_runs['distance_km']
df_runs['speed_kmh'] = (df_runs['distance_km'] / df_runs['moving_time_min']) * 60

df_runs.fillna(0, inplace=True)

# features 
X = df_runs[['distance_km', 'total_elevation_gain']]
#target variable
y = df_runs['pace_min_per_km']

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# standardize features
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# train the neural network model
#did early stopping to prevent overfitting
#nn_model = MLPRegressor(hidden_layer_sizes=(100, 50), activation='relu', solver='adam', max_iter=500, random_state=42, early_stopping=True, validation_fraction=0.1, n_iter_no_change=10)
#nn_model.fit(X_train_scaled, y_train)

#another model to see if difference in MSE
#combining to different models together
model1 = MLPRegressor(hidden_layer_sizes=(100, 50), activation='relu', solver='adam', max_iter=500, random_state=42)
model2 = MLPRegressor(hidden_layer_sizes=(50, 50), activation='relu', solver='adam', max_iter=500, random_state=42)

ensemble_model = VotingRegressor(estimators=[('model1', model1), ('model2', model2)])
ensemble_model.fit(X_train_scaled, y_train)

y_pred = ensemble_model.predict(X_test_scaled)
mse = mean_squared_error(y_test, y_pred)
print(f'Mean Squared Error: {mse}')
#for ensemble model: varries around 3-4 mse
#for nn_model: all over the place

# Plot the actual vs predicted pace
plt.figure(figsize=(10, 6))
plt.scatter(y_test, y_pred, alpha=0.5)
plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'k--', lw=2)
plt.xlabel('Actual Pace (min/km)')
plt.ylabel('Predicted Pace (min/km)')
plt.title('Actual vs Predicted Pace')
plt.show()