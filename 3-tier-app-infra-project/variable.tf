variable "rds-password" {
    description = "rds password"
    type = string
    default = "sadanand"
  
}
variable "rds-username" {
    description = "rds username"
    type = string
    default = "admin"
  
}
variable "ami" {
    description = "ami"
    type = string
    default = "ami-0157af9aea2eef346"
  
}
variable "instance-type" {
    description = "instance-type"
    type = string
    default = "t3.micro"
  
}
variable "key-name" {
    description = "pojectkey"
    type = string
    default = "projectkey"
  
}
variable "backupr-retention" {
    type = number
    default = "7"
  
}