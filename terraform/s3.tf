# S3(use Metadata)
resource "random_string" "orders_use_metadata" {
  length  = 8
  upper   = false
  special = false
}

resource "aws_s3_bucket" "orders_use_metadata" {
  bucket = "orders-use-metadata-${random_string.orders_use_metadata.id}"
}

resource "aws_s3tables_table_bucket" "orders_use_metadata" {
  name = "orders-use-metadata-${random_string.orders_use_metadata.id}"
}

# S3(not use Metadata)
resource "random_string" "orders_not_use_metadata" {
  length  = 8
  upper   = false
  special = false
}

resource "aws_s3_bucket" "orders_not_use_metadata" {
  bucket = "orders-not-use-metadata-${random_string.orders_not_use_metadata.id}"
}
