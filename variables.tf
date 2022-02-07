variable "instance_size" {
  type = string
  description = "The instance size to use (see: https://aws.amazon.com/ec2/instance-types/)"
  default = "m6i.large"
}

variable "region" {
  type = string
  description = "The region the instance should be deployed in."
  default = "us-east-1"
}

variable "ssh_key_name" {
  type = string
  description = "An SSH key to connect to the server with."
  default = "minecraft-server-key"
}

variable "ssh_key_path" {
  type = string
  description = "The path to the SSH key to use in creating the server. MAKE SURE TO SPECIFY THE PUBLIC KEY PATH!"
  default = "./ssh_key.pub"
}

variable "port" {
  type = number
  description = "The port to run minecraft on on the server."
  default = 14375
}

variable "allow_ssh" {
  type = list(string)
  description = "Other IPs you'd like to allow SSH traffic from (the current machine's WAN IP will be added automatically)."
  default = [""]
}

