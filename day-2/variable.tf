variable "ami_id" {
    description = "passing ami values"
    default = "ami-07860a2d7eb515d9a"
    type = string
  
}

variable "aws_vpc" {
    description = "passing vpc values"
    default = "10.0.0.0/20"
    type = string  
}

variable "aws_subnet" {
    description = "passing subnet values"
    default = "10.0.0.0/24"
    type = string  
  
}