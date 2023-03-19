resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_lifecycle_configuration" "lambda_bucket_lifecycle" {
  rule {
    id      = "example-rule"
    status = "Enabled"

    expiration {
      days = 1
    }

    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }

  bucket = aws_s3_bucket.lambda_bucket.id
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}

data "aws_iam_policy_document" "bucket_force_delete" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.lambda_bucket.arn]
    effect    = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }

  statement {
    actions   = ["s3:GetObject", "s3:DeleteObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.lambda_bucket.arn}/*"]
    effect    = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_force_delete" {
  bucket = aws_s3_bucket.lambda_bucket.id
  policy = data.aws_iam_policy_document.bucket_force_delete.json
}
