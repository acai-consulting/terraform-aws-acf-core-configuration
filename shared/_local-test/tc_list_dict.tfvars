configuration_add_on = {
  simple_string = "test_value"
  dict_list = [
    {
      name    = "dict1"
      value   = "value1"
      enabled = true
    },
    {
      name    = "dict2"
      value   = "value2"
      enabled = false
      nested = {
        sub_key = "sub_value"
      }
    }
  ]
  mixed_structure = {
    items = [
      {
        id   = "item1"
        tags = ["production", "critical"]
      },
      {
        id   = "item2"
        tags = ["development"]
        config = {
          timeout = 30
          retry   = true
        }
      }
    ]
  }
}
prefix = "/test"