import pandas as pd
from datetime import datetime
import json

# Load JSON data into a DataFrame
df = pd.read_json("/Users/niambashambu/Desktop/AI-RUNNING-APP/activities.json")

# Filter for runs
data = df[df['type'] == 'Run'].copy()

# Function to calculate pace (min/km)
def calculate_pace(distance: float, moving_time: int) -> float:
    if distance == 0:
        return None
    pace = (moving_time / distance) * 1000  # pace in seconds per km
    return pace / 60  # convert to minutes per km

# Function to generate recommendations based on activity data
def generate_recommendations(activity: dict) -> list:
    recommendations = []

    # Check for distance and moving_time
    if activity['distance'] is None or activity['moving_time'] is None or activity['distance'] <= 0 or activity['moving_time'] <= 0:
        recommendations.append("Insufficient data to generate recommendations.")
        return recommendations

    # Calculate pace
    pace = calculate_pace(activity['distance'], activity['moving_time'])
    
    if pace is not None:
        pace_str = f"{pace:.2f} min/km"
        recommendations.append(f"Pace for this run: {pace_str}")

        # Pacing recommendation
        if pace > 6.0:
            recommendations.append("Your pace is relatively slow. Consider incorporating interval training to improve speed.")
        elif pace < 5.0:
            recommendations.append("You are running at a good pace! Focus on maintaining this speed and building endurance.")
    
    # Elevation gain
    elevation_gain = activity.get('total_elevation_gain', 0)
    if elevation_gain > 100:
        recommendations.append("You've gained significant elevation. Adding hill workouts to your training can improve your performance on hilly terrain.")

    # Manual entry
    if activity.get('manual', False):
        recommendations.append("This activity was manually entered. Ensure your data is accurate for the best training insights.")

    # Time and Date Analysis
    try:
        start_date = datetime.fromisoformat(activity['start_date'].rstrip('Z'))
        if start_date.hour >= 18:
            recommendations.append("You did a late-night run. Ensure proper recovery and sleep to optimize performance.")
    except ValueError as e:
        recommendations.append(f"Error parsing start date: {e}")

    # Fallback recommendation if no recommendations were generated
    if not recommendations:
        recommendations.append("Keep up the good work and stay consistent with your running.")

    return recommendations

# Apply the function to each row in the DataFrame
data['recommendations'] = data.apply(lambda row: generate_recommendations(row), axis=1)

# Print recommendations


# Prepare recommendations for JSON output
recommendations_json = data[['name', 'start_date', 'recommendations']].to_dict(orient='records')

# Prepare a list of structured recommendations
structured_recommendations = []
for idx, row in data.iterrows():
    structured_recommendations.append({
        "name": row['name'],
        "start_date": row['start_date'],
        "recommendations": row['recommendations']
    })

# Log the structured recommendations JSON to stdout for debugging
print(json.dumps(structured_recommendations))  # Output valid JSON array

# Save to a JSON file (optional)
output_file = '/Users/niambashambu/Desktop/AI-RUNNING-APP/recommendations.json'
with open(output_file, 'w') as f:
    json.dump(structured_recommendations, f, indent=4)
# Save to a JSON file
