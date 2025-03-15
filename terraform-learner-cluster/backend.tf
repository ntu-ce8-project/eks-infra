terraform {
  backend "s3" {
    bucket = "sctp-ce8-tfstate"
    key    = "terraform-learner-cluster-ce8.tfstate" #Update accordingly
    region = "ap-southeast-1"
  }
}
