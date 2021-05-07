provider "aws" {
  region = "us-east-2"
}

variable "s3_bucket_name" {
   type = list(string)
   default = ["html123456", "scipts123456"]
}
resource "aws_s3_bucket" "mainbucket" {
   count = "${length(var.s3_bucket_name)}"
   bucket = "${var.s3_bucket_name[count.index]}"
   acl = "public-read"
   versioning {
      enabled = true
   }
   force_destroy = "true"
}
resource "aws_s3_bucket" "sourcebucket" {
   
   bucket = "backuplogs123456"
   acl = "public-read-write"
   versioning {
      enabled = true
   }
   force_destroy = "true"
}

data "aws_s3_bucket" "testbucket" {
  bucket="backuplogs123456"
}

resource "aws_s3_bucket_object" "uploadingHTML" {

  bucket = data.aws_s3_bucket.testbucket.id

  key    = "profile.html"

  acl    = "public-read-write"  # or can be "public-read"

  source = "index.html"

  

}