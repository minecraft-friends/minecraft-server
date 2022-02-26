variable "env" {
  type = string
  description = "The name of the env"
}

variable "region" {
  type = string
  description = "The aws region to use"
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

variable "ecs_task_cpu" {
  type = number
  description = "The cpu used by the ecs task"
  default = 256
}

variable "ecs_task_memory" {
  type = number
  description = "The cpu used by the ecs task"
  default = 512
}

variable "ecs_task_container_cpu" {
  type = number
  description = "The cpu used by the ecs task"
  default = 256
}

variable "ecs_task_container_memory" {
  type = number
  description = "The cpu used by the ecs task"
  default = 512
}
