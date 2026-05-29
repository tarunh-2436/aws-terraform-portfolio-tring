variable "website_bucket_name" {
  type = string
}

variable "logging_bucket_name" {
  type = string
}

variable "common_tags" {
  type = map(string)
  default = {
    Owner = "Tarun"
  }
}