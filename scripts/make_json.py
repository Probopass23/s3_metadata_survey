import uuid
from random import choice
import json
import secrets

from faker import Faker

fake = Faker('ja_JP')


def make_json():
  with open('../data/orders.jsonl', 'w') as f:
    for order in __orders():
        json.dump(order, f, ensure_ascii=False)
        f.write('\n')


def __orders() -> list[dict]:
  results = []
  products = __products()
  customer_ids = __customer_ids(10000)

  for customer_id in customer_ids:
    order_at = __order_at()
    num_of_product = choice([1, 2, 3, 4, 5])
    for _ in range(num_of_product):
      product = choice(products)
      results.append({
        'order_id': __order_id(),
        'customer_id': customer_id,
        'product_id': product['id'],
        'product_category': product['category'],
        'product_name': product['name'],
        'price': product['price'],
        'order_at': order_at,
      })
  
  return results


def __products() -> list[dict]:
  f = open('../data/product.json', 'r')
  return json.load(f)


def __customer_ids(n: int) -> list[str]:
  return [secrets.token_hex(8) for _ in range(n)]


def __order_id() -> str:
  return str(uuid.uuid4())


def __order_at() -> str:
  return fake.date_time_between_dates(
    datetime_start='-2y',
    datetime_end='now'
  ).strftime("%Y-%m-%d %H:%M:%S")


if __name__ == '__main__':
  make_json()
