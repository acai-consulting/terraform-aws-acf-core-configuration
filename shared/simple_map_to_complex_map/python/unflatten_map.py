import json
import sys

def unflatten_map(flattened_map, separator='/', prefix=None):
    """
    Convert a flattened dictionary with path-style keys into a nested dictionary with support for lists.
    """
    def assign(d, keys, value):
        key = keys[0]
        is_index = key.isdigit()

        if len(keys) == 1:
            if is_index:
                while len(d) <= int(key):
                    d.append(None)
                d[int(key)] = value
            else:
                d[key] = value
            return

        next_key = keys[1]
        is_next_index = next_key.isdigit()

        if is_index:
            while len(d) <= int(key):
                d.append([] if is_next_index else {})
            if d[int(key)] is None:
                d[int(key)] = [] if is_next_index else {}
            assign(d[int(key)], keys[1:], value)
        else:
            if key not in d:
                d[key] = [] if is_next_index else {}
            assign(d[key], keys[1:], value)

    nested = {}
    for key, value in flattened_map.items():
        if prefix and key.startswith(prefix):
            key = key[len(prefix):].lstrip(separator)
        elif prefix:
            continue

        parts = key.split(separator)
        if parts[0].isdigit():
            if not isinstance(nested, list):
                nested = []
        assign(nested, parts, value)
    return nested

input_text = str(sys.argv[1])
prefix = sys.argv[2] if len(sys.argv) > 2 else ''
input_map = json.loads(input_text)
unflattened_configuration_items = unflatten_map(input_map, prefix=prefix)
print(json.dumps({"result": json.dumps(unflattened_configuration_items)}))
