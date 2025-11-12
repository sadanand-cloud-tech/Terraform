variable "aws_region" {
  description = "The region in which to create the infrastructure"
  type        = string
  nullable    = false
  default     = "us-east-1" #here we need to define either us-west-1 or us-west-2 if i give other region will get error 
  validation {
    condition = var.aws_region == "us-east-1" || var.aws_region == "us-west-1"
    error_message = "The variable 'aws_region' must be one of the following regions: us-west-2, eu-west-1"
  }
}

provider "aws" {
  region = "us-east-1"
}
  


 resource "aws_s3_bucket" "dev" {
    bucket = "sadanandam59"
    
  
}

#after run this will get error like The variable 'aws_region' must be one of the following regions: us-west-2,│ eu-west-1, so it will allow any one region defined above in conditin block



## Example-2
variable "create_bucket" {
  type    = bool
  default = false
}

resource "aws_s3_bucket" "example" {
  count  = var.create_bucket ? 1 : 0
  bucket = "sadanandam61"
}

# ## Example-3
# variable "environment" {
#   type    = bool
#   default = false
# }

# resource "aws_instance" "example" {
#   count         = var.environment? 3 : 1
#   ami           = "ami-07860a2d7eb515d9a"
#   instance_type = "t3.micro"

#   tags = {
#     Name = "sada-${count.index}"
#   }
# }

# #In this case:
# #If var.environment == "prod" → count = 3
# #Else (like dev, qa, etc.) → count = 1
# #terraform apply -var="environment=dev"