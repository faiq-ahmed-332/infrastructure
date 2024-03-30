# Configure the AWS Provider
provider "aws" {
  region = var.region
}

# Build VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = "${var.vpc_enable_dns_hostnames}"
  enable_dns_support = "${var.vpc_enable_dns_support}"
  tags = {
    Name = "${var.vpc_name}"
    Owner = "${var.owner}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Internet Gateway
resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.vpc.id}"
 tags = {
    Name = "${var.vpc_name}"
    Owner = "${var.owner}"
  }
}

# Public Subnets and Routing Tables
module "sn_public" {
  source = "../TF_common_modules/tf_aws_sn_rtr_acl"
  vpc_name = "${var.vpc_name}"
  vpc_id = "${aws_vpc.vpc.id}"
  owner = "${var.owner}"
  subnets = "${var.vpc_subnets_public}"
  availability_zones = "${var.vpc_availability_zones}"
  map_public_ip_on_launch = true
  name_tag = "public"
}

resource "aws_route" "external" {
  route_table_id = "${module.sn_public.routing_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id     = "${aws_internet_gateway.ig.id}"
}

module "sn_private_appdata" {
  source = "../TF_common_modules/tf_aws_sn_rtr_acl"
  vpc_name = "${var.vpc_name}"
  vpc_id = "${aws_vpc.vpc.id}"
  owner = "${var.owner}"
  subnets = "${var.vpc_subnets_private_appdata}"
  availability_zones = "${var.vpc_availability_zones}"
  map_public_ip_on_launch = false
  name_tag = "private_appdata"
}


# Cloudtrail
resource "aws_cloudtrail" "cloudtrail-dev" {
    name = "tf-cloudtrail-dev"
    s3_bucket_name = "${var.s3_bucket_cloudtrail_logs}"
    s3_key_prefix = "/dev-cloudtrail"
    include_global_service_events = true
}

resource "aws_cloudwatch_log_group" "var-log-messages" {
  name = "/var/log/messages"
  retention_in_days = 30
}
resource "aws_cloudwatch_log_group" "var-log-audit" {
  name = "/var/log/audit/audit.log"
  retention_in_days = 30
}
resource "aws_cloudwatch_log_group" "var-log-secure" {
  name = "/var/log/secure"
  retention_in_days = 30
}

resource "aws_iam_instance_profile" "base-log-profile" {
        name = "base-log-profile"
            role = "${aws_iam_role.log-role.name}"
        }

resource "aws_iam_role" "log-role" {
    name = "log-role"
    path = "/"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}

EOF
}

resource "aws_iam_role_policy" "log-policy" {
    name = "log-policy"
    role = "${aws_iam_role.log-role.id}"
    policy = <<EOF
{
    "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams",
        "logs:CreateLogGroup"
    ],
      "Resource": [
        "arn:aws:logs:*:*:*"
    ]}]}
EOF
}

# Create an S3 Endpoint
resource "aws_vpc_endpoint" "dev_s3_endpoint" {
    vpc_id = "${aws_vpc.vpc.id}"
    service_name = "com.amazonaws.eu-west-2.s3"
    route_table_ids = ["${module.sn_private_appdata.routing_table_id}"]

}

# Create terraform key pair

resource "aws_key_pair" "terraform" {
    key_name = "terraform"
    public_key = "${file("terraform_dev.pub")}"
}


resource "aws_s3_bucket" "img" {
  bucket        = var.s3_bucket_img
  #policy        = "${data.aws_iam_policy_document.bucket_policy.json}"
  acl ="private"
  force_destroy = true
  #region        = var.region
  tags = {
    Name        = var.s3_bucket_img
      }
   server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  
}




resource "aws_s3_bucket" "doc" {
  bucket        = var.s3_bucket_doc
  #policy        = "${data.aws_iam_policy_document.bucket_policy.json}"
  acl ="private"
  force_destroy = true
  #region        = var.region
  tags = {
    Name        = var.s3_bucket_img
      }
   server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  
}

resource "aws_s3_account_public_access_block" "example" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}