#Creating an s3 bucket
resource "aws_s3_bucket" "project_bucket" {
  bucket = "dhruv-three-tier-bucket"

  tags = {
    Name = "dhruv-three-tier-bucket"
  }
}

resource "aws_s3_bucket_versioning" "s3_bucket_versions" {
  bucket = aws_s3_bucket.project_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

#Creating IAM role for EC2 instance
resource "aws_iam_role" "web_instance_role" {
  name               = "web-instance-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
  EOF

  tags = {
    name = "EC2-IAM-ROLE"
  }
}

#Attaching policies to role
resource "aws_iam_role_policy_attachment" "ssm_managed_instance" {
  role       = aws_iam_role.web_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "s3_read_only" {
  role       = aws_iam_role.web_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

#Create EC2 instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "web-profile"
  role = aws_iam_role.web_instance_role.name
}

