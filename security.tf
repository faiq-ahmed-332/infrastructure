# This section declares security groups which are important
# at the infrastructure level.  Some are virtual (containing no rules)
# and are only used as source or destination SG in security groups
# declared in the upper layers
# A summary of the SGs declared in this file are given below:
#   sg_public_pub_inst - default SG for all public instances in the public subnets (elb)
#   sg_appdata_pub_inst  - default SG for all instances in the appdata subnets(database and instances)

# Security Group - Public Facing Instance
resource "aws_security_group" "sg_public_pub_inst" {
  name = "sg_public_pub_inst"
  description = "Public Security Group for the general Instance"
  vpc_id = "${aws_vpc.vpc.id}"
 tags = {
    Name = "sg_public_pub_inst"
    Owner = "${var.owner}"
  }
}

resource "aws_security_group_rule" "sgr_public_pub_inst_in1" {
  type = "ingress"
  from_port = "22"
  to_port = "22"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_public_pub_inst.id}"
}

resource "aws_security_group_rule" "sgr_public_pub_inst_in1" {
  type = "ingress"
  from_port = "8080"
  to_port = "8080"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_public_pub_inst.id}"
}

resource "aws_security_group" "sg_public_smtp" {
  name = "sg_public_smtp"
  description = "Public Security Group for SMTP endpoint"
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name = "sg_public_smtp"
    Owner = "${var.owner}"
  }
}

resource "aws_security_group_rule" "sgr_public_smtp_in1" {
  type = "ingress"
  from_port = "25"
  to_port = "25"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_public_smtp.id}"
}

resource "aws_security_group_rule" "sgr_public_smtp_in2" {
  type = "ingress"
  from_port = "465"
  to_port = "465"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_public_smtp.id}"
}

resource "aws_security_group_rule" "sgr_public_pub_inst_eg1" {
  type = "egress"
  from_port = "80"
  to_port = "80"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_public_pub_inst.id}"
}

resource "aws_security_group_rule" "sgr_public_pub_inst_eg2" {
  type = "egress"
  from_port = "443"
  to_port = "443"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_public_pub_inst.id}"
}

resource "aws_security_group_rule" "sgr_public_pub_inst_eg3" {
  type = "egress"
  from_port = "0"
  to_port = "65535"
  protocol = "tcp"
  cidr_blocks = ["${aws_vpc.vpc.cidr_block}"]
  security_group_id = "${aws_security_group.sg_public_pub_inst.id}"
}


resource "aws_security_group" "sg_appdata_prv_inst" {
    name = "sg_appdata_prv_inst"
    vpc_id = "${aws_vpc.vpc.id}"
    description = "Private security group for the appdata instances"
   tags = {
        Name = "sg_appdata_prv_inst"
        Owner = "${var.owner}"
    }

    ingress {
        from_port = "22"
        to_port = "22"
        protocol = "tcp"
        cidr_blocks = ["${aws_vpc.vpc.cidr_block}"]
    }

ingress {
        from_port = "25"
        to_port = "25"
        protocol = "tcp"
        cidr_blocks = ["${aws_vpc.vpc.cidr_block}"]
    }

ingress {
        from_port = "465"
        to_port = "465"
        protocol = "tcp"
        cidr_blocks = ["${aws_vpc.vpc.cidr_block}"]
    }

ingress {
        from_port = "587"
        to_port = "587"
        protocol = "tcp"
        cidr_blocks = ["${aws_vpc.vpc.cidr_block}"]
    }

   
    egress {
        from_port = "53"
        to_port = "53"
        protocol = "udp"
        cidr_blocks = ["${aws_vpc.vpc.cidr_block}"]
    }

egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    prefix_list_ids = [aws_vpc_endpoint.dev_s3_endpoint.prefix_list_id]
  }

egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

 
}


resource "aws_default_network_acl" "default" {
 default_network_acl_id = aws_vpc.vpc.default_network_acl_id
 
ingress {
    protocol   = "tcp"
     rule_no    = 100
     action     = "allow"
     cidr_block = "0.0.0.0/0"
     from_port  = 1024
     to_port    = 65535
   }

ingress {
    protocol   = "udp"
     rule_no    = 150
     action     = "allow"
     cidr_block = "0.0.0.0/0"
     from_port  = 1024
     to_port    = 65535
   }

ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

ingress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  

 
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}
