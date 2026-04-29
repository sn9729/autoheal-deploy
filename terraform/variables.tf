variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the existing AWS key pair for SSH access"
  type        = string
}

variable "app_port" {
  description = "Port the application runs on"
  type        = number
  default     = 3000
}

variable "mongo_uri" {
  description = "MongoDB Atlas connection string"
  type        = string
}

variable "session_secret" {
  description = "Session secret for the app"
  type        = string
  default     = "autoheal_super_secret"
}

variable "node_env" {
  description = "Node environment"
  type        = string
  default     = "production"
}
