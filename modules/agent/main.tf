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

  dynamic "document_processing_config" {
    for_each = each.value.document_processing != null ? [1] : []

    content {
      dynamic "chunking_config" {
        for_each = each.value.document_processing.chunking.enabled ? [1] : []

        content {
          layout_based_chunking_config {
            chunk_size                = each.value.document_processing.chunking.chunk_size
            include_ancestor_headings = each.value.document_processing.chunking.include_headings
          }
        }
      }

      default_parsing_config {
        dynamic "digital_parsing_config" {
          for_each = each.value.document_processing.default_parser == "digital" ? [1] : []

          content {}
        }
        dynamic "ocr_parsing_config" {
          for_each = each.value.document_processing.default_parser == "ocr" ? [1] : []

          content {
            use_native_text = true
          }
        }
        dynamic "layout_parsing_config" {
          for_each = each.value.document_processing.default_parser == "layout" ? [1] : []

          content {}
        }
      }

      dynamic "parsing_config_overrides" {
        for_each = each.value.document_processing.parsing_overrides != null ? toset(each.value.document_processing.parsing_overrides) : []

        content {
          file_type = parsing_config_overrides.value.file_type

          dynamic "ocr_parsing_config" {
            for_each = parsing_config_overrides.value.parsing_config == "ocr" ? [1] : []

            content {
              use_native_text = parsing_config_overrides.value.use_native_text
            }
          }

          dynamic "digital_parsing_config" {
            for_each = parsing_config_overrides.value.parsing_config == "digital" ? [1] : []

            content {}
          }

          dynamic "layout_parsing_config" {
            for_each = parsing_config_overrides.value.parsing_config == "layout" ? [1] : []

            content {}
          }
        }
      }
    }
  }
}

resource "random_id" "this" {
  for_each = var.datastores

  byte_length = 4
}
