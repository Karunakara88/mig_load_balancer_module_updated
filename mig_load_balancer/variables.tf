variable "project_id" {
  description = "Project identification"
  default     = "prj-sandbox-infra-01"
  type        = string
}

variable "image_id" {
  description = "image id"
  default     = "debian-cloud/debian-11"
  type        = string
}

variable "region" {
  description = "region"
  default     = "us-central1"
  type        = string
}

variable "zone" {
  description = "zone"
  default     = "us-central1-a"
  type        = string
}

variable "cidr" {
  description = "CIDR Range"
  default     = "10.2.0.0/16"
  type        = string
}
