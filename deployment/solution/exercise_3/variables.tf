# Hier eure Initialen + Zahl als default eintragen (z. B. default = "hkr100"),
# sonst fragt Terraform bei jedem plan/apply/destroy danach.
variable "initialen" {
  type        = string
  description = "Initialen + Zahl, z. B. hkr100. Macht die Namen eindeutig (Storage Accounts weltweit)."

  validation {
    condition     = can(regex("^[a-z0-9]{3,12}$", var.initialen))
    error_message = "Nur Kleinbuchstaben und Ziffern, 3 bis 12 Zeichen, z. B. hkr100."
  }
}

variable "location" {
  type        = string
  description = "Azure-Region. Azure for Students erlaubt nur bestimmte Regionen (Portal: Policy > Assignments > Allowed resource deployment regions). austriaeast, weil Standard_B2ats_v2 bei Azure for Students in switzerlandnorth nicht verfügbar ist."
  default     = "austriaeast"
}

variable "common_tags" {
  type        = map(string)
  description = "Tags für alle Ressourcen"
  default     = { Owner = "hkr", Project = "cds206" }
}

variable "ssh_public_key_path" {
  type        = string
  description = "Pfad zum öffentlichen SSH-Schlüssel. Noch keinen? Einmal ssh-keygen -t rsa -b 4096 ausführen (Enter für alle Fragen)."
  default     = "~/.ssh/id_rsa.pub"
}
