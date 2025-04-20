import json

import boto3


sqs = boto3.client('sqs', region_name="us-east-1")
queue_url = 'https://sqs.us-east-1.amazonaws.com/xxxxxxxxx/xxxxxxx'

def enqueue():
  orders = __load_json()
  n = 10

  for i in range(0, len(orders), n):
    chunked_orders = orders[i:i + n]
    sqs.send_message_batch(
      QueueUrl=queue_url,
      Entries=__message_entries(chunked_orders)
    )
    print(f"progress: {i}/{len(orders)}")

def __load_json() -> list[dict]:
  f = open('../data/orders.jsonl', 'r')
  return [json.loads(l) for l in f.readlines()]

def __message_entries(orders: list[dict]):
   return [
     {
       'Id': order['order_id'],
        'MessageBody': json.dumps(order),
     }
     for order in orders
   ]


if __name__ == '__main__':
  enqueue()
