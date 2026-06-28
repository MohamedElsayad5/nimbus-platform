output "bucket_name" {
  value = google_storage_bucket.monitoring.name
}

output "bucket_url" {
  value = google_storage_bucket.monitoring.url
}
