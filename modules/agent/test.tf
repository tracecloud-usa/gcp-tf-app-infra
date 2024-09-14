resource "null_resource" "this" {
  for_each = { for k, v in var.datastores : k => v if v.gcs_bucket_name != null }

  depends_on = [
    google_discovery_engine_data_store.this
  ]

  # Use triggers to force recreation if needed
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      #!/bin/bash
      set -e

      # Set variables
      PROJECT_ID="${each.value.project}"
      LOCATION="${each.value.location}"
      DATA_STORE_ID="${google_discovery_engine_data_store.this[each.key].data_store_id}"
      GCS_BUCKET_NAME="${each.value.gcs_bucket_name}"
      ACCESS_TOKEN="${data.google_client_config.current.access_token}"

      # Determine the correct API endpoint based on LOCATION
      if [ "$LOCATION" == "global" ]; then
        API_ENDPOINT="https://discoveryengine.googleapis.com"
      else
        API_ENDPOINT="https://$LOCATION-discoveryengine.googleapis.com"
      fi

      # Make the API call to import data
      curl -X POST \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
          "gcsSource": {
            "inputUris": ["gs://'"$GCS_BUCKET_NAME"'/*.pdf"],
            "dataSchema": "content"
          },
          "reconciliationMode": "INCREMENTAL"
        }' \
        "$API_ENDPOINT/v1/projects/$PROJECT_ID/locations/$LOCATION/collections/default_collection/dataStores/$DATA_STORE_ID/branches/0/documents:import"
    EOT
  }
}


data "google_client_config" "current" {}
