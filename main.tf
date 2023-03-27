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

# Create an IAM role
resource "google_project_iam_custom_role" "remotion_sa" {
  role_id     = "RemotionSA"
  title       = "Remotion API Service Account"
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
resource "google_service_account" "remotion_sa" {
  account_id   = "remotion-sa"
  display_name = "Remotion Service Account"
}

# Bind the IAM role to the service account
resource "google_project_iam_member" "remotion_sa" {
  project = "{{project-id}}"
  role    = google_project_iam_custom_role.remotion_sa.id
  member  = "serviceAccount:${google_service_account.remotion_sa.email}"
}

# Enable Cloud Run API
resource "google_project_service" "cloud_run" {
  project = "{{project-id}}"
  service = "run.googleapis.com"
}