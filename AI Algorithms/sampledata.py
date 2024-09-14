import pandas as pd
import numpy as np
import random
from datetime import datetime, timedelta


def generate_sample_data(num_samples=50):
    def random_dates(start, end, n=10):
        start_u = start.timestamp()
        end_u = end.timestamp()
        return [datetime.fromtimestamp(random.uniform(start_u, end_u)) for _ in range(n)]

    start_date = datetime(2024, 1, 1)
    end_date = datetime(2024, 9, 1)

    data = []
    for _ in range(num_samples):
        distance = random.randint(3000, 15000)  # Distance in meters
        moving_time = random.randint(900, 3600)  # Moving time in seconds
        total_elevation_gain = random.randint(0, 200)  # Elevation gain in meters
        average_speed = np.round(distance / moving_time, 2)  # Average speed in m/s
        start_date_random = random_dates(start_date, end_date, 1)[0]
        
        activity = {
            "id": random.randint(100000000, 999999999),
            "name": f"Run {random.randint(1, 100)}",
            "type": "Run",
            "distance": distance,
            "moving_time": moving_time,
            "elapsed_time": moving_time + random.randint(0, 300),
            "total_elevation_gain": total_elevation_gain,
            "start_date": start_date_random.isoformat(),
            "average_speed": average_speed,
            "max_speed": average_speed + random.uniform(0.5, 1.5)
        }
        
        data.append(activity)

    df = pd.DataFrame(data)
    return df

if __name__ == "__main__":
    df = generate_sample_data()
    df.to_csv("sample_data.csv", index=False)
