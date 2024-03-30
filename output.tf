# VPC Configuration
output "vpc_id"                     { value = "${aws_vpc.vpc.id}" }
output "region"                     { value = "${var.region}" }
output "vpc_cidr"                   { value = "${aws_vpc.vpc.cidr_block}" }
output "public_subnet_ids"          { value = "${module.sn_public.subnets}" }
output "public_routing_table_id"   { value = "${module.sn_public.routing_table_id}" }
#output "public_network_acl_id"   { value = "${module.sn_public.network_acl_id}" }
output "private_availability_zones" { value = "${var.vpc_availability_zones}" }
output "public_availability_zones"  { value = "${var.vpc_availability_zones}" }
#output "root_dir"                   { value = "${var.root_dir}" }
output "private_subnet_appdata_ids"         { value = "${module.sn_private_appdata.subnets}" }
output "private_routing_table_appdata_id"   { value = "${module.sn_private_appdata.routing_table_id}" }
#output "private_network_acl_appdata_id"   { value = "${module.sn_private_appdata.network_acl_id}" }

# S3 Bucket Names
output "s3_bucket_dev_state" { value = "${var.s3_bucket_dev_state}" }
output "s3_bucket_elb_logs" { value = "${var.s3_bucket_elb_logs}" }
output "s3_bucket_cloudtrail_logs" { value = "${var.s3_bucket_cloudtrail_logs}" }

# Security Groups
output "sg_appdata_prv_inst_id"      { value = "${aws_security_group.sg_appdata_prv_inst.id}" }
output "sg_public_pub_inst_id"      { value = "${aws_security_group.sg_public_pub_inst.id}" }
# S3 VPC Endpoint
output "dev_s3_endpoint" { value = "${aws_vpc_endpoint.dev_s3_endpoint.id}" }

# Domain zone id
#output "fmk_main_domain_zone_id" { value = "${aws_route53_zone.fmk_main.id}"}

# Subdomain zone ids
#output "dev_fmk_subdomain_zone_id" { value = "${aws_route53_zone.dev.id}"}

output "dev_s3_endpoint_prefix-list_id" { value = "${aws_vpc_endpoint.dev_s3_endpoint.prefix_list_id}" }
