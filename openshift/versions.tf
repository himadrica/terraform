terraform {
  required_version = ">= 1.5.0"

  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.70.0"
    }
  }

  # Remote backend for state management (optional - uncomment and configure)
  # backend "s3" {
  #   bucket = "terraform-state-bucket"
  #   key    = "openshift/terraform.tfstate"
  #   region = "us-south"
  #   
  #   endpoints = {
  #     s3 = "https://s3.us-south.cloud-object-storage.appdomain.cloud"
  #   }
  #   
  #   # IBM Cloud COS requires these settings
  #   skip_credentials_validation = true
  #   skip_region_validation      = true
  #   skip_metadata_api_check     = true
  #   skip_requesting_account_id  = true
  #   use_path_style              = false
  #   
  #   # Authentication: Set these environment variables before running terraform init:
  #   # export AWS_ACCESS_KEY_ID="<your-cos-hmac-access-key>"
  #   # export AWS_SECRET_ACCESS_KEY="<your-cos-hmac-secret-key>"
  #   # 
  #   # To create HMAC credentials:
  #   # 1. Go to IBM Cloud Console > Resource List > Cloud Object Storage instance
  #   # 2. Service Credentials > New Credential
  #   # 3. Enable "Include HMAC Credential" toggle
  #   # 4. Use the access_key_id and secret_access_key from the credentials
  # }
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}
