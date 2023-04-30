# Define the VPC CIDR block
variable "vpc_cidr" {
  default = "10.10.0.0/16"
}

# Define the name of the VPC
variable "vpc_name" {
  default = "fh-workshop-vpc-new"
}

# Define the DHCP options
variable "dhcp_options" {
  default = {
    domain_name          = "ec2.internal"
    domain_name_servers  = "AmazonProvidedDNS"
  }
}

# Define the availability zones for the subnets
variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
}