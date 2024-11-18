variable "domain_name" {
    type = string
    description = "hostname for the host"
}

variable "mongo_key" {
    type = string
    description = "openssl key for mongo security"
}

variable "nodes_ips" {
    type = string
    description = "list of ips involve"
}

variable "primary_node" {
    type = string
    default = "mongo-1"
}

variable "secondary_node1" {
    type = string
    default = "mongo-2"
}

variable "secondary_node2" {
    type = string
    default = "mongo-3"
}

variable "nodes_hosts" {
    type = string
    description = "list of hosts involve"
}

variable "private_ip" {
    type = string
    description = "private ip address"
}

variable "instance_type" {
    type = string
    description = "ec2 instance type"
}

variable "ami_id" {
    type = string
    description = "EC2 AMI ID"
}

variable "key_name" {
    type = string
    description = "EC2 Key Pair for SSH"
}

variable "subnet_id" {
    type = string   
}

variable "security_group_id" {
    type = string
}

variable "prefix" {
    type = string
    default = "dta"
}

variable "volume_size" {
    type = string
    description = "EBS volume storage size"
}

variable "repl_name" {
    type = string
    default = "rs0"
}

variable "root_user" {
    type = string
}

variable "root_pass" {
    type = string
}

variable "admin_user" {
    type = string
}

variable "admin_pass" {
    type = string
}

variable "availability_zone" {
    type = string
}