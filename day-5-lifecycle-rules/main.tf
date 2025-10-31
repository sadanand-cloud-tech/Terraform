provider "aws" {
  
}

#creating instance
resource "aws_instance" "dev" {
    ami ="ami-0f25b2d51fb3386b7" 
    instance_type = "t3.micro"
    tags ={
        Name ="dev"
    }
    lifecycle {
  ignore_changes = [tags]
}
lifecycle {
  create_before_destroy = true
}
lifecycle {
  ignore_changes = [tags]
}
}



