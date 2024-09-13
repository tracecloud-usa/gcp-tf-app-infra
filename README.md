# gcp-tf-prod-infra
Terraform for the GCP Application and Database Infrastructure


## License

This repository is proprietary and is not licensed for use, distribution, or modification. All rights reserved. You must obtain explicit permission from the author to use any part of this code.


## Usage
1. run the root module to deploy the web server
2. go to helpers directory and run tf plan to generate yaml files for playbooks
3. run the ansible playbooks to deploy the website

## Helpers
1. generate yaml files for ansible playbooks by running tf plan in helpers directory
2. bash script for renaming test docs to random strings is located at `helpers/scripts/doc_naming.sh`