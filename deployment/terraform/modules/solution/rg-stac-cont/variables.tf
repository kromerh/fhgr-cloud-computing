variable "name" {
  description = "Name of the resources"
  type        = string
}

variable "initialen" {
  description = "Initialen + Zahl, z. B. hkr100"
  type        = string
}

variable "location" {
  description = "Azure location"
  type        = string
  default     = "switzerlandnorth"
}

variable "common_tags" {
  description = "Tags für alle Ressourcen"
  type        = map(string)
  default     = {}
}

variable "account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
}

variable "container_access_type" {
  description = "Storage container access type"
  type        = string
  default     = "private"
}
