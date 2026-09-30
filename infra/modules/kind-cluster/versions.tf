terraform {
  required_version = ">= 1.3.0"

  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.11"
    }
  }
}
