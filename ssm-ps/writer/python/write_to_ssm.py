import argparse
import json
import boto3
from botocore.config import Config
from botocore.exceptions import ClientError

def assume_role(role_arn):
    sts = boto3.client('sts')
    resp = sts.assume_role(RoleArn=role_arn, RoleSessionName="TerraformSSMSession")
    creds = resp['Credentials']
    return dict(
        aws_access_key_id=creds['AccessKeyId'],
        aws_secret_access_key=creds['SecretAccessKey'],
        aws_session_token=creds['SessionToken'],
    )

def parameter_exists(ssm, name):
    try:
        ssm.get_parameter(Name=name)
        return True
    except ClientError as e:
        if e.response['Error']['Code'] == 'ParameterNotFound':
            return False
        raise

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--map', required=True)
    parser.add_argument('--role-arn', required=True)
    parser.add_argument('--kms-key-id', required=False)
    parser.add_argument('--tags', required=False, default='{}')
    parser.add_argument('--parameter_overwrite', required=False, default='false')
    args = parser.parse_args()

    creds = assume_role(args.role_arn)
    boto_config = Config(
        retries = {
            'max_attempts': 5,
            'mode': 'standard'
        }
    )
    ssm = boto3.client('ssm', config=boto_config, **creds)

    param_map = json.loads(args.map)
    tags = [{'Key': k, 'Value': v} for k, v in json.loads(args.tags).items()]
    overwrite = args.parameter_overwrite.lower() == "true"

    for k, v in param_map.items():
        exists = parameter_exists(ssm, k)
        kwargs = {
            'Name': k,
            'Value': v,
            'Type': 'SecureString' if args.kms_key_id else 'String',
        }
        if args.kms_key_id:
            kwargs['KeyId'] = args.kms_key_id

        try:
            if not exists:
                # Parameter existiert nicht: mit Tags anlegen
                kwargs['Tags'] = tags
                kwargs['Overwrite'] = False
                ssm.put_parameter(**kwargs)
                print(f"Created {k} with tags {tags}")
            else:
                # Parameter existiert: Wert überschreiben, Tags separat setzen
                kwargs['Overwrite'] = overwrite
                ssm.put_parameter(**kwargs)
                print(f"Updated {k} value")
                if tags:
                    ssm.add_tags_to_resource(
                        ResourceType='Parameter',
                        ResourceId=k,
                        Tags=tags
                    )
                    print(f"Updated tags for {k}: {tags}")
        except Exception as e:
            print(f"Error storing {k}: {e}")

if __name__ == "__main__":
    main()