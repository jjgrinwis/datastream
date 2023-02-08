
variable "group_name" {
    description = "Akamai group to use this resource in"
    type        = string
}

# our properties that are going to use this DS instance
# they should be using the same delivery configuration type!
variable "property_names" {
    description = "Name of the property that's going to use DataStream"
    type = set(string)
}

# elastic password, set via 'export export TF_VAR_elastic_password="xxxx"'
variable "elastic_password" {
  type        = string
  description = "Elastic Password, sensitive"
  sensitive   = true
}