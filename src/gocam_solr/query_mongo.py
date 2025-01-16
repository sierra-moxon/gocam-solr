from load_gocam import create_store_client
from pprint import pprint

if __name__ == "__main__":

    # Create a LinkML store clientx
    client = create_store_client()

    collection = client.get_collection("models")
    fc = collection.query_facets()
    pprint(fc["annotations"])