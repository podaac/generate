# generate

Generate is a program that downloads data from the Ocean Biology Processing Group (OBPG). Generate processes the data is downloads to create three Level 2P datasets.

Generate downloads the following data:
- MODIS Aqua: https://oceancolor.gsfc.nasa.gov/data/aqua/
- MODIS Terra: https://oceancolor.gsfc.nasa.gov/data/terra/
- VIIRS: https://oceancolor.gsfc.nasa.gov/data/viirs-snpp/

The API for searching and downloading data can be found here: https://oceancolor.gsfc.nasa.gov/data/download_methods/#api

Generate outputs the following data:
- MODIS_A-JPL-L2P-v2019.0: https://podaac.jpl.nasa.gov/dataset/MODIS_A-JPL-L2P-v2019.0
- MODIS_T-JPL-L2P-v2019.0: https://podaac.jpl.nasa.gov/dataset/MODIS_T-JPL-L2P-v2019.0
- VIIRS_NPP-JPL-L2P-v2016.2: https://podaac.jpl.nasa.gov/dataset/VIIRS_NPP-JPL-L2P-v2016.2

## components

Generate consists of several components:
- download list creator: Creates list of files to download (search and download from OBPG).
- downloader: Downloads files from lists created by the download list creator.
- combiner: Combines downloaded files into a single NetCDF file.
- processor: Processes combined files into final L2P granule NetCDF file.
- error_handler: Handles AWS Batch job failures by logging and notification.

Component repo links:
- download list creator: https://github.com/podaac/generate_download_list_creator
- downloader: https://github.com/podaac/generate_downloader
- combiner: https://github.com/podaac/generate_combiner
- processor: https://github.com/podaac/generate_processor
- error_handler: https://github.com/podaac/generate_error_handler

## aws infrastructure

The Generate workflow includes the following AWS services:
- AWS Batch compute environment with launch template and user-data script, job queue, and scheduling policy for each dataset.
- Elastic file system for the following components: downloader, combiner, processor.
- IAM roles and policies for Batch and ECS permissions.
- S3 bucket to hold final L2P output.
- Security groups to support EFS network traffic in VPC.

## terraform 

Deploys AWS infrastructure and stores state in an S3 backend using a DynamoDB table for locking. The top-level `terraform` directory contains AWS infrastructure that applies to all components. Each component may have additional terraform files for deploying AWS resources, see each components `README.md` for details.

To deploy:
1. Edit `terraform.tfvars` for environment to deploy to.
2. Edit `terraform_conf/backed-{prefix}.conf` for environment deploy.
3. Initialize terraform: `terraform init -backend-config=terraform_conf/backend-{prefix}.conf`
4. Plan terraform modifications: `terraform plan -out=tfplan`
5. Apply terraform modifications: `terraform apply tfplan`

`{prefix}` is the account or environment name.