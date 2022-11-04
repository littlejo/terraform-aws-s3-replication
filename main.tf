data "aws_s3_bucket" "source" {
  bucket = var.source_bucket_name
}

data "aws_s3_bucket" "destination" {
  bucket   = var.destination_bucket_name
  provider = aws.dst
}

data "aws_iam_policy_document" "assume_role" {
  statement {

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [data.aws_s3_bucket.source.arn]
  }
  statement {
    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = ["${data.aws_s3_bucket.source.arn}/*"]
  }
  statement {
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags"
    ]

    resources = ["${data.aws_s3_bucket.destination.arn}/*"]
  }
}

resource "aws_iam_role" "this" {
  name = var.iam_role_name

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "this" {
  name = var.iam_policy_name

  policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_s3_bucket_replication_configuration" "this" {
  role   = aws_iam_role.this.arn
  bucket = data.aws_s3_bucket.source.id

  rule {
    status = "Enabled"

    destination {
      bucket        = data.aws_s3_bucket.destination.arn
      storage_class = "STANDARD"
    }
  }
}
