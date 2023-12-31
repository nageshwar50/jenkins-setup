# EC2 Instance Variables
region         = "us-west-2"
ami_id         = "ami-0efcece6bed30fd98"
instance_type  = "t2.micro"
key_name       = "nageshwar"
instance_count = 1
volume-size = 25

# VPC id
vpc_id  = "vpc-0ce1c1c34c9d1afe2"
subnet_ids     = ["subnet-02da9422af0bbc93c"]


# Ec2 Tags
name        = "Jenkins"
owner       = "nageshwar"
environment = "dev"
cost_center = "pandey-commerce"
application = "cicd"

# EC2 Instance Variables
region         = "us-west-2"
ami_id         = "ami-03fd0aa14bd102718"
instance_type  = "t2.micro"
key_name       = "pandey"
instance_count = 1
volume-size = 25

# VPC id
vpc_id  = "vpc-0cac018cd52b8d4c1"
subnet_ids     = ["subnet-0b010c9585354c154"]

# Ec2 Tags
name        = "Jenkins"
owner       = "nageshwar"
environment = "dev"
cost_center = "pandey-commerce"
application = "cicd"

# CIDR Ingress Variables
create_ingress_cidr        = true
ingress_cidr_from_port     = [22, 80, 443, 8080]  # List of from ports
ingress_cidr_to_port       = [22, 80, 443, 8080]  # List of to ports
ingress_cidr_protocol      = ["tcp", "tcp", "tcp", "tcp"]  # Protocol for all rules
ingress_cidr_block         = ["0.0.0.0/0", "0.0.0.0/0", "0.0.0.0/0", "0.0.0.0/0"]
ingress_cidr_description   = ["SSH", "HTTP", "HTTPS", "Jenkins"]

# CIDR Egress Variables
create_egress_cidr    = true
egress_cidr_from_port = [0]
egress_cidr_to_port   = [0]
egress_cidr_protocol  = ["-1"]
egress_cidr_block     = ["0.0.0.0/0"]



