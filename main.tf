terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.58.0"
    }
  }

  required_version = ">= 1.4.1"
}

provider "google" {
  project = "{{project-id}}"
  region  = "us-central1"
  zone    = "us-central1-c"
}

# Enable required APIs
module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 14.2"

  project_id = "{{project-id}}"

  activate_apis = [
    "oslogin.googleapis.com"
  ]

  disable_services_on_destroy = false
  disable_dependent_services  = false
}

# Create an IAM role
resource "google_project_iam_custom_role" "tf_sa_role" {
  role_id     = "tfRemotionSA"
  title       = "tf Remotion API Service Account"
  description = "Allow the service account to manage necessary resources for Remotion Cloud Run rendering."
  permissions = [
    "iam.serviceAccounts.actAs",
    "run.routes.invoke",
    "run.services.create",
    "run.services.list",
    "run.services.update",
    "storage.buckets.get",
    "storage.buckets.list",
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.list",
    "run.services.getIamPolicy",
    "run.services.setIamPolicy"
  ]
}

# Create a service account
resource "google_service_account" "tf_remotion_sa" {
  account_id   = "tf-remotion-sa"
  display_name = "Remotion Service Account"
}

# Bind the IAM role to the service account
resource "google_project_iam_member" "tf_remotion_sa" {
  role    = google_project_iam_custom_role.tf_sa_role.id
  member  = "serviceAccount:${google_service_account.tf_remotion_sa.email}"
}