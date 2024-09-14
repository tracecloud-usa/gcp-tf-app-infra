variable "datastores" {
  type = map(object({
    name           = string
    location       = string
    project        = string
    solution_types = list(string)
    content_config = object({
      type                         = string
      create_advanced_site_search  = bool
      skip_default_schema_creation = bool
    })
  }))
  default = {}
}

variable "solution_types" {
  type = map(string)
  default = {
    chat           = "SOLUTION_TYPE_CHAT"
    search         = "SOLUTION_TYPE_SEARCH"
    recommendation = "SOLUTION_TYPE_RECOMMENDATION"
    gen_chat       = "SOLUTION_TYPE_GENERATIVE_CHAT"
  }
}
