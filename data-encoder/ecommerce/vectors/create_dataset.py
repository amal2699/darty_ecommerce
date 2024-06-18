#!/usr/bin/env python3

from sentence_transformers import SentenceTransformer, util
import products
import logging


# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

print("Loading text embedding model...")
model_txt = SentenceTransformer('all-MiniLM-L6-v2')
err_msg = "Image not resolved for id : "

# Load the original products dataset
print("Loading the original products dataset...")
products_dataset = products.load_products_dataset()

# Use the embedding model to calculate vectors for all products
print("Calculating text vectors for all products...")

products_vectors = products.calculate_products_vectors(
    model_txt, products_dataset)
print("Text vectors calculation completed.")


# Use the embedding model to calculate image vectors for all products
print("Calculating image vectors for all products...")

products_image_vectors = products.calculate_products_image_vectors_clip(
    products_dataset)
print("Image vectors calculation completed.")


print("Integrating vectors into the dataset...")

# Create the new products dataset by creating a new field with the embedding vector
for idx in range(len(products_dataset)):
    try:
        products_dataset[idx]["product_vector"] = products_vectors[idx].tolist()
        products_dataset[idx]["product_image_vector"] = products_image_vectors[idx].tolist(
        )
    except Exception:
        print(f'{err_msg}{products_dataset[idx]["id"]}')


print("Exporting the new products dataset...")

# Export the new products dataset for all formats
products.export_products_json(products_dataset)
print("Dataset export completed successfully.")
