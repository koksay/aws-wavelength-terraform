variable "AWS_REGION" {
  description = "AWS region, e.g. us-east-1"
  type        = string
  default     = "us-east-1"
}

variable "AWS_PUBLIC_AZ" {
  description = "AWS Availability Zone for public subnet (bastion host)"
  type        = string
  default     = "us-east-1a"
}

variable "AWS_WL_AZ" {
  description = "AWS Availability Zone for the Wavelength subnet"
  type        = string
  default     = "us-east-1-wl1-nyc-wlz-1"
}

variable "PUBLIC_KEY" {
  description = "SSH Public Key for bastion host connection"
  type        = string
  sensitive   = true
}

variable "PRIVATE_KEY_FILE" {
  description = "SSH Private Key file for bastion host to WL hosts connection"
  type        = string
}