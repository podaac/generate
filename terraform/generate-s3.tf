# S3 Bucket to hold final L2P granules
resource "aws_s3_bucket" "aws_s3_bucket_final_granules" {
  bucket = "${var.prefix}-l2p-granules"
  tags   = { Name = "${var.prefix}-l2p-granules" }
}

resource "aws_s3_bucket_public_access_block" "aws_s3_bucket_idl_server_public_block" {
  bucket                  = aws_s3_bucket.aws_s3_bucket_final_granules.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "aws_s3_bucket_idl_server_ownership" {
  bucket = aws_s3_bucket.aws_s3_bucket_final_granules.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aws_s3_bucket_final_granules_encryption" {
  bucket = aws_s3_bucket.aws_s3_bucket_final_granules.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = "aws/s3"
    }
  }
}

# Bucket to hold download lists
resource "aws_s3_bucket" "aws_s3_bucket_dlc" {
  bucket = "${var.prefix}-download-lists"
  tags   = { Name = "${var.prefix}-download-lists" }
}

resource "aws_s3_bucket_public_access_block" "aws_s3_bucket_dlc_public_block" {
  bucket                  = aws_s3_bucket.aws_s3_bucket_dlc.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "aws_s3_bucket_dlc_ownership" {
  bucket = aws_s3_bucket.aws_s3_bucket_dlc.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aws_s3_bucket_dlc_encryption" {
  bucket = aws_s3_bucket.aws_s3_bucket_dlc.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = "aws/s3"
    }
  }
}