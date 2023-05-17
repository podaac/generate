# Download List Creator
resource "aws_ecr_repository" "download_list_creator" {
  name                 = "${var.prefix}-download-list-creator"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = false
  }
}

# Partition & Submit
resource "aws_ecr_repository" "partition_submit" {
  name                 = "${var.prefix}-partition-submit"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = false
  }
}

# Downloader
resource "aws_ecr_repository" "downloader" {
  name                 = "${var.prefix}-downloader"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = false
  }
}

# Combiner
resource "aws_ecr_repository" "combiner" {
  name                 = "${var.prefix}-combiner"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = false
  }
}

# Processor
resource "aws_ecr_repository" "processor" {
  name                 = "${var.prefix}-processor"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = false
  }
}

# Uploader
resource "aws_ecr_repository" "uploader" {
  name                 = "${var.prefix}-uploader"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = false
  }
}

# License Returner
resource "aws_ecr_repository" "license_returner" {
  name                 = "${var.prefix}-license-returner"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = false
  }
}

# Reporter
resource "aws_ecr_repository" "reporter" {
  name                 = "${var.prefix}-reporter"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = false
  }
}