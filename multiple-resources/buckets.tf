resource "aws_s3_bucket" "multiple_s3" {
  count = 5
  bucket = "dhruv-bucket-practice-${count.index + 1}"
}

resource "aws_instance" "multiple_instance" {
  count = 5
  ami = "ami-0b4624933067d393a"
  key_name = "dhruv-key-pair-Ohio"
  instance_type = "t2.micro"

  tags = {
    Name = "instance-${count.index + 1}"
  }
}

resource "aws_instance" "pulled_instance" {
    ami                                  = "ami-0b4624933067d393a"
    availability_zone                    = "us-east-2b"
    instance_type                        = "t2.micro"
    key_name                             = "dhruv-key-pair-Ohio"
    tags                                 = {
        "Name" = "instance-1"
    }
    tags_all                             = {
        "Name" = "instance-1"
    }
    tenancy                              = "default"
    vpc_security_group_ids               = [
        "sg-0bee42e0b407434fe",
    ]

    capacity_reservation_specification {
        capacity_reservation_preference = "open"
    }

    credit_specification {
        cpu_credits = "standard"
    }

    enclave_options {
        enabled = false
    }

    metadata_options {
        http_endpoint               = "enabled"
        http_put_response_hop_limit = 2
        http_tokens                 = "required"
        instance_metadata_tags      = "disabled"
    }
}