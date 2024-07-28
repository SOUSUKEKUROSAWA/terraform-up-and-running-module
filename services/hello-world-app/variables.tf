variable "server_port" {
    description = "The port the server will use for HTTP requests"
    type = number
    default = 8080
}

variable "instance_type" {
    description = "The type of EC2 Instances to run (e.g. t2.micro)"
    type = string
}

variable "min_size" {
    description = "The minimum number of EC2 Instances in the ASG"
    type = number
}

variable "max_size" {
    description = "The maximum number of EC2 Instances in the ASG"
    type = number
}

# for_eachによるインラインブロックの反復の確認用
variable "custom_tags" {
    description = "Custom tags to set on the Instances in the ASG"
    type = map(string)
    default = {}
}

variable "enable_autoscaling" {
    description = "If set to true, enable auto scaling"
    type = bool
}

variable "ami" {
    description = "The AMI to run in the cluster"
    type = string
    default = "ami-0fb653ca2d3203ac1"
}

variable "server_text" {
    description = "The text the web server should return"
    type = string
    default = "Hello, World"
}

variable "environment" {
    description = "The name of the environment we're deploying to"
    type = string
}