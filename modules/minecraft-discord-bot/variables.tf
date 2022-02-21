variable "env" {
  type = string
  description = "The name of the env"
}

variable "tags" {
  default     = {}
  description = "Tags to add to all resources"
  type        = map(string)
}

variable "ecs_subnet_id" {
  type = string
  description = "the subnet used by the ecs service"
}

variable "config_bucket_name" {
  type = string
  description = "The name of the bucket used for the discord bot config"
}

variable "config_bucket_key_name" {
  type = string
  description = "The name of the bucket key used for the discord bot config"
}

variable "ecs_task_image" {
  type = string
  description = "The image used by the ecs task"
}
