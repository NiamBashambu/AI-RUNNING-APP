import pandas as pd
from datetime import datetime

# Load JSON data into a DataFrame
df = pd.read_json("/Users/niambashambu/Desktop/AI-RUNNING-APP/activities.json")

# Filter for runs
data = df[df['type'] == 'Run'].copy()

# Function to calculate pace (min/km)
def calculate_pace(distance, moving_time):
    if distance == 0:
        return None
    pace = (moving_time / distance) * 1000  # pace in seconds per km
    return pace / 60  # convert to minutes per km

# Function to generate recommendations based on activity data
#need to make the recconmendations change based off the runners actual performance
def generate_recommendations(activity):
    recommendations = []

    # Calculate pace
    pace = calculate_pace(activity['distance'], activity['moving_time'])
    
    if pace:
        pace_str = f"{pace:.2f} min/km"
        recommendations.append(f"Pace for this run: {pace_str}")

        # Pacing recommendation
        if pace > 6.0:  # assuming 6 min/km is slower
            recommendations.append("Your pace is relatively slow. Consider incorporating interval training to improve speed.")
        elif pace < 5.0:  # assuming 5 min/km is faster
            recommendations.append("You’re running at a good pace! Focus on maintaining this speed and building endurance.")

    # Elevation gain
    elevation_gain = activity.get('total_elevation_gain', 0)
    if elevation_gain > 100:
        recommendations.append("You've gained significant elevation. Adding hill workouts to your training can improve your performance on hilly terrain.")

    # Manual entry
    if activity.get('manual', False):
        recommendations.append("This activity was manually entered. Ensure your data is accurate for the best training insights.")

    # Time and Date Analysis
    start_date = datetime.fromisoformat(activity['start_date'].replace('Z', '+00:00'))
    if start_date.hour >= 18:
        recommendations.append("You did a late-night run. Ensure proper recovery and sleep to optimize performance.")

    return recommendations

# Apply the function to each row in the DataFrame
data['recommendations'] = data.apply(lambda row: generate_recommendations(row), axis=1)

# Print recommendations
for idx, row in data.iterrows():
    print(f"Recommendations for activity '{row['name']}' on {row['start_date']}:")
    for rec in row['recommendations']:
        print(f"- {rec}")
    print()