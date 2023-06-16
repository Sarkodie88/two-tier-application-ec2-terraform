variable "vpc_name" {
  type     = string
  nullable = false
}


variable "private_subnet_name" {
  type     = string
  nullable = false
}


variable "public_subnet_name" {
  type     = string
  nullable = false
}


variable "public_route_table_name" {
  type     = string
  nullable = false
}

variable "private_route_table_name" {
  type     = string
  nullable = false
}

variable "instance_security_group_name" {
  type     = string
  nullable = false
}

variable "instance_role_name" {
  type     = string
  nullable = false
}


# Define a map of instances to create
variable "instances" {
  type = map(object({
    ami             = string
    instance_type   = string
    target_instance = string
    tags            = map(string)
  }))

}


variable "target_groups" {
  type = map(object({
    name            = string
    port            = string
    target_instance = string
    tags            = map(string)
  }))

}


variable "health_check" {
  type = map(string)
}