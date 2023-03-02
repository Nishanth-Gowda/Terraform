variable "myelasticapp" {
  default = "MyApplication"
}

variable "beanstalkappenv" {
  default = "myenv"
}

variable "solution_stack_name" {
  default = "64bit Amazon Linux 2 v3.4.4 running Python 3.8"
}

variable "tier" {
  default = "WebServer"
}
 
variable "vpc_id" {
    default = "vpc-0ddb47357d6007df9"
}
variable "public_subnets" {
    default = ["subnet-0a9815b576a7b0f79", "subnet-03b4f674ef84bac0d"]
}