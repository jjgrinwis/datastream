# for cloud usage these vars have been defined in terraform cloud as a set
# Configure the Akamai Provider to use betajam credentials
provider "akamai" {
  edgerc         = "~/.edgerc"
  config_section = "betajam"
}

# just use group_name to lookup our contract_id and group_id
# this will simplify our variables file as this contains contract and group id
# use "akamai property groups list" to find all your groups 
data "akamai_contract" "contract" {
  group_name = var.group_name
}

# now loookup the different property id's
data "akamai_property" "example" {
    for_each = var.property_names
    name = each.value
}

# get the property id's, strip the prd and convert to numbers
locals {
    property_ids = [for property in data.akamai_property.example: tonumber(trim(property.id, "prp_"))]
}

# create a datastream resource with elastic as an exmaple.
resource "akamai_datastream" "stream" {
    active             = false
    config {
        format             = "JSON"
        frequency {
            time_in_sec = 60
        }
    }
    contract_id        = data.akamai_contract.contract.id

    # some example data fiels
    # field can be found here: https://techdocs.akamai.com/datastream2/reference/data-set-parameters-1
    dataset_fields_ids = [
        1002, 1005, 1006
    ]
    group_id           = data.akamai_contract.contract.group_id
    property_ids       = local.property_ids
    stream_name        = "ES_TF_example"

    # next two var's can't be changed (yet)
    stream_type        = "RAW_LOGS"
    template_name      = "EDGE_LOGS"

    # example with the elastic connector
    elasticsearch_connector {
        connector_name = "es_tf_test"
        endpoint        = "https://es.great-demo.com/_bulk"
        user_name = "elastic"

        # we should be using Hasicorp Vaul for this
        # for the time being using env var.
        password = var.elastic_password
        index_name = "tf_test"
    }
}