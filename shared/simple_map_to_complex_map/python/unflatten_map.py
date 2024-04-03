import json
import sys

def unflatten_map(flattened_map, separator='/', prefix=None):
    """
    Convert a flattened dictionary with concatenated keys into a nested dictionary.

    :param flattened_dict: Flattened dictionary with paths as keys.
    :param separator: Separator used in the flattened keys.
    :return: Nested dictionary.
    """
    nested_dict = {}
    for key, value in flattened_map.items():
        # Check if the key starts with the prefix (if provided) and adjust accordingly
        if prefix and key.startswith(prefix):
            # Adjust the key by removing the prefix and the following separator (if present)
            adjusted_key = key[len(prefix):].lstrip(separator)
        elif prefix:
            # Skip keys that do not start with the prefix
            continue
        else:
            adjusted_key = key

        parts = adjusted_key.split(separator)
        d = nested_dict
        for part in parts[:-1]:
            if part not in d:
                d[part] = {}
            d = d[part]
        d[parts[-1]] = value
    return nested_dict


input_text = str(sys.argv[1])
prefix = sys.argv[2] if len(sys.argv) > 2 else ''
input_map = json.loads(input_text)
unflattened_configuration_items = unflatten_map(input_map, prefix=prefix)
print(json.dumps({"result": json.dumps(unflattened_configuration_items)}))
