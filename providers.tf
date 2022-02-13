locals {
  region = split(".", terraform.workspace)[0]
  full_env_name = split(".", terraform.workspace)[1]
  environment = split("-", local.full_env_name)[0]
  project_name = replace(local.full_env_name, format("%s%s", local.environment, "-"), "")
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 1.1.0"

  backend "s3" {
    bucket = "terraform-20220212115800"
#    key = "${local.region}/${local.project_name}/${local.environment}"
    key = "minecraft-server.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "terraform-20220212115800"
  }
}

provider "aws" {
  region = local.region
}
