from datetime import datetime
import json
import os

import boto3


s3 = boto3.client('s3')


def handler(event, context):
  use_metadata = (os.getenv('USE_METADATA', 'False') == 'True')
  s3_bucket = os.getenv('S3_BUCKET', '')
  print(use_metadata, s3_bucket)

  print(event)

  records = event['Records']
  len_records = len(records)
  for i, message in enumerate(records):
    order = json.loads(message['body'])
    if (use_metadata):
      __put_with_metadata(s3_bucket, order)
    else:
      __put_without_metadata(s3_bucket, order)
    print(f"progress: {i+1}/{len_records}")


def __put_with_metadata(s3_bucket: str, order: dict):
  s3.put_object(
    Bucket=s3_bucket,
    Body=json.dumps(order),
    Key=f"{order['order_id']}.json",
    ServerSideEncryption='AES256',
    Metadata={
      'order-id': order['order_id'],
      'order-at': order['order_at'],
      'customer-id': order['customer_id'],
      'product-id': order['product_id'],
      'product-category': order['product_category'],
    }
  )


def __put_without_metadata(s3_bucket: str, order: dict):
  order_at = datetime.strptime(order['order_at'], "%Y-%m-%d %H:%M:%S")
  key = f"{order_at.year}/{order_at.month}/{order_at.day}/{order['order_id']}.json"
  s3.put_object(
    Bucket=s3_bucket,
    Body=json.dumps(order),
    Key=key,
    ServerSideEncryption='AES256',
  )
