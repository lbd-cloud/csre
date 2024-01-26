variable "max_node_count" {
  description = "Max number of nodes in the GKE node pool"
  type        = number
}

variable "region" {
  description = "Region where the GKE node pool will be located"
  type        = string
}
