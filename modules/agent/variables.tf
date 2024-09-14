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
    document_processing = optional(object({
      chunking = object({
        enabled          = bool
        chunk_size       = number
        include_headings = bool
      })
      default_parser = string
      parsing_overrides = list(object({
        file_type       = string
        parsing_config  = string
        use_native_text = bool
      }))
    }))
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
