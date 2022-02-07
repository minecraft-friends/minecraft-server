resource "aws_s3_bucket" "snapshot_bucket" {
  bucket_prefix = "minecraft-snapshots"
  tags = local.tags
}

resource "aws_s3_bucket_object" "seed_snapshot" {
  bucket = aws_s3_bucket.snapshot_bucket.bucket
  key    = "seed_snapshot.zip"
  source = var.snapshot
}