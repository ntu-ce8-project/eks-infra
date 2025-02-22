output "users" {
  value = [for obj in local.merged_users : obj["arn"]]
}
