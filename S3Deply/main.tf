provider "aws" {
  region = "us-east-2"
}

variable "s3_bucket_name" {
   type = "list"
   default = ["html", "scipts", "backup_logs"]
}
resource "aws_s3_bucket" "sourceBucket" {
   count = "${length(var.s3_bucket_name)}"
   bucket = "${var.s3_bucket_name[count.index]}"
   acl = "public"
   versioning {
      enabled = true
   }
   force_destroy = "true"
}