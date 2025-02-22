data "aws_iam_group" "ce8" {
  group_name = "sctp-ce-8-learner"
}

data "aws_iam_group" "instructor" {
  group_name = "instructor"
}

data "aws_availability_zones" "available" {
  state = "available"
}
