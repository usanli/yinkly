terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}


provider "google" {
  project = var.project_id
  region  = var.region
}

module "vm" {
  source         = "./modules/vm"
  name           = "yinkly-db"
  zone           = var.zone
  machine_type   = var.db_machine_type
  startup_script = file("${path.module}/modules/vm/startup-db.sh")
}

module "gke" {
  source     = "./modules/gke"
  name       = "yinkly-gke"
  region     = var.region
  node_count = var.node_count
  node_type  = var.node_machine_type
}

module "fn" {
  source       = "./modules/fn"
  name         = "yinkly-redirect"
  runtime      = var.fn_runtime
  entry_point  = var.entry_point
  trigger_http = true
  project_id   = var.project_id
  region       = var.fn_region
}

