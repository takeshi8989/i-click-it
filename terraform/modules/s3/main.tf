resource "aws_s3_bucket" "iclicker_bucket" {
  bucket = "${var.bucket_name}-${var.account_id}"
}

resource "aws_s3_object" "src_files" {
  for_each = fileset("${path.root}/../src", "**")

  bucket = aws_s3_bucket.iclicker_bucket.id
  key    = "src/${each.key}"
  source = "${path.root}/../src/${each.key}"
  acl    = "private"
}

resource "aws_s3_object" "class_schedules_utc_json" {
  bucket = aws_s3_bucket.iclicker_bucket.id
  key    = "class_schedules_utc.json"
  source = "${path.root}/../class_schedules_utc.json"
}
