variable "instance_size" {
  type = string
  description = "The instance size to use (see: https://aws.amazon.com/ec2/instance-types/)"
  default = "m6i.large"
}