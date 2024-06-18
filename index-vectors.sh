#!/bin/bash

set -eo pipefail

# The directory where your database file is located
DATA_DIR="C:/Users/MSI GF63/Desktop/chores/data-encoder/ecommerce/vectors/data"

# The name of your database file
DATABASE_FILE="products-vectors-bdd.json"

# The number of records per bulk upload
BULK_MAX=1000

# Check if the database file exists
if [ ! -f "${DATA_DIR}/${DATABASE_FILE}" ]; then
  echo "Database file not found: ${DATA_DIR}/${DATABASE_FILE}"
  exit 1
fi

# Convert JSON to NDJSON
echo "Converting JSON to NDJSON"
jq -c '.[]' "${DATA_DIR}/${DATABASE_FILE}" > "${DATA_DIR}/${DATABASE_FILE}.nd"

# Split the NDJSON file
echo "Splitting ${DATABASE_FILE}.nd to a maximum of ${BULK_MAX} rows"
split -l "${BULK_MAX}" "${DATA_DIR}/${DATABASE_FILE}.nd" "${DATA_DIR}/${DATABASE_FILE}.splitted.nd."

# Convert each splitted file to ES bulk format and populate to Elasticsearch
for f in "${DATA_DIR}/${DATABASE_FILE}.splitted.nd."*; do
  echo "Converting ${f} to ES bulk format"
  awk '{print "{\"index\": {}}\n" $0}' "${f}" > "${f}.bulk"
  echo "Populating data from ${f}.bulk to Elasticsearch"
  curl -sS -o /dev/null -u 'elastic:ElasticRocks' -X POST "localhost:9200/ecommerceee/_bulk?pretty" --data-binary @"${f}.bulk" -H 'Content-type:application/x-ndjson';
done

echo "Data upload complete"
