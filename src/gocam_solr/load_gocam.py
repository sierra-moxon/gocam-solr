import os
import json
import requests
from linkml_store import Client

def create_store_client():
    db_client = Client()
    database_client = db_client.attach_database("mongodb://localhost:27017", "gocam")
    return database_client

def load_models(models_directory: str, database_client):
    """Load the GO-CAM models from the given directory."""
    collection = database_client.create_collection("models", recreate_if_exists=True)

    for file in os.listdir(models_directory):
        if file.endswith(".json"):
            with open(os.path.join(models_directory, file), 'r') as f:
                model = json.load(f)
                collection.store(model)

def load_model(model_file, db_client, collection="models"):
    """load a single model file into a mongodb collection"""
    if db_client.get_collection(collection) is None:
        collection = db_client.create_collection(collection)
    else:
        collection = db_client.get_collection(collection)
    if model_file.endswith(".json"):
        with open(model_file, 'r') as f:  # Corrected parentheses
            model = json.load(f)
            collection.insert(model)

def parse_metadata_file(metadata_path):
    """Parse the JSON metadata file and return a dictionary."""
    try:
        with open(metadata_path, 'r') as file:
            metadata = json.load(file)
        return metadata
    except Exception as e:
        raise RuntimeError(f"Error reading metadata file: {e}")

def download_metadata_file(url, destination):
    """Download the metadata JSON file from a URL."""
    try:
        response = requests.get(url)
        response.raise_for_status()  # Raise an error for HTTP issues
        with open(destination, 'w') as file:
            file.write(response.text)
        print(f"Metadata file downloaded to {destination}")
    except requests.exceptions.RequestException as e:
        raise RuntimeError(f"Error downloading metadata file: {e}")

def download_resource_file(resource_id,
                           base_url="https://live-go-cam.geneontology.io/product/json/low-level/"):
    """Download the JSON file for the given resource ID."""
    try:
        url = f"{base_url}{resource_id}.json"
        response = requests.get(url)
        response.raise_for_status()  # Raise an error for HTTP issues
        return response.json()
    except requests.exceptions.RequestException as e:
        raise RuntimeError(f"Error downloading resource {resource_id}: {e}")

def store_file_in_temp(data, resource_id, temp_dir):
    """Store the downloaded JSON data in a temporary folder."""

    # Define the file path (modify as needed)
    file_path = os.path.join(temp_dir, f"{resource_id}.json")

    # Skip if the file already exists
    if os.path.exists(file_path):
        print(f"Skipping resource_id: {resource_id} (file already exists: {file_path})")
        return

    try:
        file_path = os.path.join(temp_dir, f"{resource_id}.json")
        with open(file_path, 'w') as file:
            json.dump(data, file, indent=4)
        print(f"Stored {resource_id}.json in {temp_dir}")
    except Exception as e:
        raise RuntimeError(f"Error saving resource {resource_id}: {e}")

def process_resources(metadata_path, client):
    """Main function to process resources and store them in a temporary folder."""
    # Parse the metadata file
    metadata = parse_metadata_file(metadata_path)

    # Create a temporary directory
    temp_dir = os.path.join('/tmp', 'gocam_json_files')
    os.makedirs(temp_dir, exist_ok=True)
    print(f"Using temporary directory: {temp_dir}")
    client.create_collection("models", recreate_if_exists=True)
    for resource_url, resource_ids in metadata.items():
        print(resource_url)
        counter = 0
        base_url = "https://live-go-cam.geneontology.io/product/json/low-level/"
        for resource_id in resource_ids:
            try:
                if counter > 50 or not resource_id[0].isdigit():
                    break
                else:
                    counter += 1
                    # Download and store the JSON file for each ID
                    data = download_resource_file(resource_id, base_url)
                    store_file_in_temp(data, resource_id, temp_dir)
                    load_model(os.path.join(temp_dir, f"{resource_id}.json"), client)
            except RuntimeError as e:
                print(e)


if __name__ == "__main__":
    # URL to download the metadata file
    metadata_url = "https://live-go-cam.geneontology.io/product/json/provider-to-model.json"

    # Temporary file to save the metadata.json
    metadata_file_path = "metadata.json"

    # Download the metadata file
    download_metadata_file(metadata_url, metadata_file_path)

    # Create a LinkML store clientx
    client = create_store_client()

    # Process the resources using the downloaded metadata
    process_resources(metadata_file_path, client)
    # load_models("/tmp/gocam_json_files", client)

    collection = client.get_collection("models")
    fc = collection.query_facets()



