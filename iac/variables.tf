variable "max_node_count" {
  description = "Max. number of nodes in the GKE node pool"
  type        = number
}

variable "region" {
  description = "Region for the GKE node pool"
  type        = string
}
