
variable "userid" {
    default = "user03"
}

variable "region" {
    default = "us-west-1"
}

variable "az1" {
    default = "us-west-1a"
}

variable "az2" {
    default = "us-west-1b"
}

variable "vpc1-cidr" {
    default = "10.3.0.0/16"
}

variable "subnet1-cidr" {
    default = "10.3.1.0/24"
}

variable "subnet2-cidr" {
    default = "10.3.2.0/24"
}

variable "ami-id" {
    default = "ami-088c153f74339f34c"
}

variable "alb-account-id" {
    default = "027434742980"
}

variable "cloud9-cidr" {
    default = "54.151.70.195/32"
}
