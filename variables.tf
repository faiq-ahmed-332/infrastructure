# S3 Buckets
variable "s3_bucket_dev_state" { default = "dev-state" }
variable "s3_bucket_elb_logs" { default = "dev-elb-logs" }
variable "s3_bucket_cloudtrail_logs" { default = "dev-cloudtrail-logs-v1" }


variable "s3_bucket_doc" { default = "documents" }
variable "s3_bucket_img" { default = "user-profile-pictures" }
# AWS SSH Key Pair
variable "key_name" { default = "terraform" }

# Provider

variable "region" { default = "eu-west-2" }

# VPC
variable "vpc_name" { default = " dev1" }
variable "vpc_cidr_block" { default = "172.16.0.0/20" }
variable "vpc_enable_dns_support" { default = true }
variable "vpc_enable_dns_hostnames" { default = true }
variable "vpc_subnets_public" { default = "172.16.1.0/24,172.16.2.0/24" }
variable "vpc_subnets_private_appdata" { default = "172.16.3.0/24,172.16.4.0/24" }
variable "vpc_availability_zones" { default = "eu-west-2a,eu-west-2b" }
# INBOUND PROXY
#variable "sg_inbound_proxy_name" { default = "PublicInternetInboundProxy" }
#variable "sg_inbound_proxy_description" { default = "Allow internet traffic into the inbound proxy" }
#variable "asg_inbound_proxy_name" { default = "PublicInternetInboundProxy" }
#variable "lc_inbound_proxy_name" { default = "PublicInternetInboundProxy" }

variable "s3_versioning" { default = "true" }
#variable "root_dir" { default = "~/NLEDP/fmk/terraform/providers/aws/fmk/dev" }

# SSL Cert and Key
#variable "fmkappdata_ssl_cert" { default = "../files/certificates/fmkappdata.info.crt" }
#variable "fmkappdata_ssl_key"  { default = "../files/certificates/fmkappdata.info.key" }

# Owner
variable "owner" { default = "Terraform" }


