# example wiring, not meant to apply as-is - needs your own STACKIT project and service account key

terraform {
  required_providers {
    stackit = {
      source = "stackitcloud/stackit"
    }
  }
}

provider "stackit" {
  default_region = "eu01"
}

module "ske" {
  source = "../../modules/stackit-ske"

  project_id = "00000000-0000-0000-0000-000000000000"
  name       = "idp-demo"
}
