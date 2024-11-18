resource "aws_s3_bucket" "iclicker_bucket" {
  bucket = "${var.bucket_name}-${var.account_id}"
}

resource "aws_s3_object" "main_py" {
  bucket = aws_s3_bucket.iclicker_bucket.id
  key    = "main.py"
  source = "${path.root}/../main.py"
}

resource "aws_s3_object" "class_schedules_utc_json" {
  bucket = aws_s3_bucket.iclicker_bucket.id
  key    = "class_schedules_utc.json"
  source = "${path.root}/../class_schedules_utc.json"
}
