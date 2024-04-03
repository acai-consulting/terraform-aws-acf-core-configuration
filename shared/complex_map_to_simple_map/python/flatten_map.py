import json
import sys

def flatten_map(input_map, parent_key='', separator='/'):
    items = []
    for key, value in input_map.items():
        new_key = f"{parent_key}{separator}{key}" if parent_key else key
        if isinstance(value, dict):
            items.extend(flatten_map(value, new_key, separator=separator).items())
        else:
            items.append((new_key, value))
    return dict(items)

input_text = sys.argv[1]
prefix = sys.argv[2] if len(sys.argv) > 2 else ''
input_map = json.loads(input_text)
flattened_configuration_items = flatten_map(input_map, parent_key=prefix)
print(json.dumps({"result": json.dumps(flattened_configuration_items)}))
