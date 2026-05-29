variable "bucket_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "allow_acls" {
  type    = bool
  default = false
}