resource "google_discovery_engine_data_store" "this" {
  for_each = var.datastores

  location                     = each.value.location
  project                      = each.value.project
  data_store_id                = "${each.value.name}-${random_id.this[each.key].hex}"
  display_name                 = each.value.name
  industry_vertical            = "GENERIC"
  content_config               = each.value.content_config.type
  solution_types               = [for solutions in each.value.solution_types : lookup(var.solution_types, solutions)]
  create_advanced_site_search  = each.value.content_config.create_advanced_site_search
  skip_default_schema_creation = each.value.content_config.skip_default_schema_creation
}

resource "random_id" "this" {
  for_each = var.datastores

  byte_length = 8
}
