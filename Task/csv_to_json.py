import pandas as pd

# Function to convert CSV to JSON
def csv_to_json(csv_file_path, json_file_path):
    # Load the CSV data into a pandas DataFrame
    data = pd.read_csv(csv_file_path)

    # Convert the entire DataFrame to a JSON format, in a record-oriented manner
    json_data = data.to_json(orient='records', lines=False)

    # Save the JSON data to a file
    with open(json_file_path, 'w') as f:
        f.write(json_data)

# Use the function with your specific file paths
csv_file_path = 'Stimulii/mc24_prototypes.csv'  # Replace with your CSV file path
json_file_path = 'Task/mc_patterns.json'  # Replace with your desired JSON file path

# Convert the file
csv_to_json(csv_file_path, json_file_path)