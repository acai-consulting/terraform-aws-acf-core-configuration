import json
import sys

def flatten_map(input_map, parent_key='', separator='/'):
    items = []
    if isinstance(input_map, dict):
        for key, value in input_map.items():
            new_key = f"{parent_key}{separator}{key}" if parent_key else key
            items.extend(flatten_map(value, new_key, separator=separator).items())
    elif isinstance(input_map, list):
        for idx, item in enumerate(input_map):
            new_key = f"{parent_key}{separator}{idx}"
            items.extend(flatten_map(item, new_key, separator=separator).items())
    else:
        items.append((parent_key, input_map))
    return dict(items)

input_text = sys.argv[1]
prefix = sys.argv[2] if len(sys.argv) > 2 else ''
input_map = json.loads(input_text)
flattened_configuration_items = flatten_map(input_map, parent_key=prefix)
print(json.dumps({"result": json.dumps(flattened_configuration_items)}))
