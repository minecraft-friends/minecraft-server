variable "arch" {
  type = string
  description = "The architecture of the server"
  default = "arm64"
}

variable "instance_size" {
  type = string
  description = "The instance size to use (see: https://aws.amazon.com/ec2/instance-types/)"
  default = "m6g.xlarge"
}

variable "ssh_key_path" {
  type = string
  description = "The path to the SSH key to use in creating the server. MAKE SURE TO SPECIFY THE PUBLIC KEY PATH!"
  default = "./ssh_key.pub"
}

# TODO: fix this so it works and actually templates the port into the server config
variable "port" {
  type = number
  description = "The port to run minecraft on on the server."
  default = 14375
}

variable "snapshot" {
  type = string
  description = "The path to a server snapshot (.zip) to load on the server"
  default = "snapshot.zip"
}

variable "disk_space" {
  type = number
  description = "The amount of space to allocate for the server's primary storage"
  default = 50
}

variable "zip_root" {
  type = string
  description = "The name of the root folder in the snapshot zip"
  default = "forge-v4"
}

variable "start_script" {
  type = string
  description = "The name of the start script (minus the `.sh` extension)"
  default = "start"
}

variable "snapshot_bucket" {
  type = string
  description = "The name of the bucket to fetch initial snapshots from"
  default = "minecraft-snapshots"
}