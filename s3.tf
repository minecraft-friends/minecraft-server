resource "aws_s3_bucket" "snapshot_bucket" {
  bucket = "${local.env}-minecraft-snapshots-298urhg"
  tags = local.tags
}

resource "aws_s3_bucket_object" "minecraft-systemd-unit" {
  bucket = aws_s3_bucket.snapshot_bucket.bucket
  key    = "minecraft.service"
  source = "minecraft.service"
}