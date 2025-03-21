terraform {
  backend "s3" {
    bucket = "sctp-ce8-tfstate"
    key    = "ce8-github-deployer-role.tfstate" #Update accordingly
    region = "ap-southeast-1"
  }
}
