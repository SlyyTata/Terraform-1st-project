resource "aws_s3_bucket" "terraform-static-web-s3" {
  bucket = "slyy-terraform-test-static-bucket"

  tags = {
    Name        = "My test static bucket"
  }
}

resource "null_resource" "terraform-static-web-s3-website" {
  depends_on = [
    aws_s3_bucket.terraform-static-web-s3,
  ]

  provisioner "local-exec" {
    command = <<EOF
      mkdir -p /tmp/git-to-s3-repo
      
      git clone https://github.com/cloudacademy/static-website-example.git /tmp/git-to-s3-repo
      
      rm -rf /tmp/git-to-s3-repo/.git
      
      aws s3 sync /tmp/git-to-s3-repo/ s3://${aws_s3_bucket.terraform-static-web-s3.id}/
      
      rm -rf /tmp/git-to-s3-repo
    EOF
  }
}

resource "aws_s3_bucket_public_access_block" "terraform-static-web-s3-public-access-block" {
  bucket = aws_s3_bucket.terraform-static-web-s3.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "terraform-static-web-s3-website-configuration" {
  bucket = aws_s3_bucket.terraform-static-web-s3.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "terraform-static-web-s3-ownership-controls" {
  bucket = aws_s3_bucket.terraform-static-web-s3.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "terraform-static-web-s3-acl" {
  depends_on = [
    aws_s3_bucket_public_access_block.terraform-static-web-s3-public-access-block,
    aws_s3_bucket_ownership_controls.terraform-static-web-s3-ownership-controls,
  ]

  bucket = aws_s3_bucket.terraform-static-web-s3.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "terraform-static-web-s3-policy" {
  depends_on = [
    aws_s3_bucket_acl.terraform-static-web-s3-acl,
  ]

  bucket = aws_s3_bucket.terraform-static-web-s3.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.terraform-static-web-s3.arn}/*"
      }
    ]
  })
}