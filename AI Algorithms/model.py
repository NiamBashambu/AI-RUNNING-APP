import pandas as pd
import numpy as np

from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error

import matplotlib.pyplot as plt

# Sample data (following format of strava api)
#once get mongodb we can link these
from sampledata import generate_sample_data 



df = generate_sample_data()

df_runs = df[df['type'] == 'Run'].copy()

df_runs['distance_km'] = df_runs['distance'] / 1000  # meters to kilometers
df_runs['moving_time_min'] = df_runs['moving_time'] / 60  # seconds to minutes

df_runs['pace_min_per_km'] = df_runs['moving_time_min'] / df_runs['distance_km']
df_runs['speed_kmh'] = (df_runs['distance_km'] / df_runs['moving_time_min']) * 60  # km/h

df_runs.fillna(0, inplace=True)

print(df_runs[['id', 'name', 'distance_km', 'moving_time_min', 'pace_min_per_km', 'speed_kmh']])


X = df_runs[['distance_km', 'total_elevation_gain']]  # Features
y = df_runs['pace_min_per_km']  # Target variable (pace)

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
#linear regression model
#obv will get more advanced this is bare bones
model = LinearRegression()
model.fit(X_train, y_train)


y_pred = model.predict(X_test)
mse = mean_squared_error(y_test, y_pred)
#how model fits data
print(f'Mean Squared Error: {mse}')
#how pace changes with changes in elevation and distance
print(f'Coefficients: {model.coef_}')
print(f'Intercept: {model.intercept_}')

#speed analysis over time

df_runs['start_date'] = pd.to_datetime(df_runs['start_date'])
df_runs = df_runs.sort_values(by='start_date')

# Calculate rolling average of speed over time to detect trends
df_runs['rolling_speed_kmh'] = df_runs['speed_kmh'].rolling(window=3).mean()

# Plot the speed trend over time 
#shows runner whether or not they are improving
plt.figure(figsize=(10, 6))
plt.plot(df_runs['start_date'], df_runs['speed_kmh'], label='Speed (km/h)')
plt.plot(df_runs['start_date'], df_runs['rolling_speed_kmh'], label='Rolling Avg Speed (km/h)', linestyle='--')
plt.xlabel('Date')
plt.ylabel('Speed (km/h)')
plt.title('Speed Over Time')
plt.legend()
plt.show()


#obv use better models going forward
#and when get mongodb we need to link