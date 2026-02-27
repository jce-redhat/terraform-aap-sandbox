# create an instance profile with read-only access to EC2.  this is useful
# in environments where access is granted with short-lived STS tokens, which
# make using AWS credentials for dynamic inventory syncs less useful.
data "aws_iam_policy_document" "assume_aap_instance_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role" {
  count = var.create_instance_profile ? 1 : 0

  name               = "aap_instance_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_aap_instance_role.json
}

resource "aws_iam_role_policy_attachment" "ec2_read_only" {
  count = var.create_instance_profile ? 1 : 0

  role       = aws_iam_role.role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "aap_instance_profile" {
  count = var.create_instance_profile ? 1 : 0

  name = "aap_instance_profile"
  role = aws_iam_role.role[0].name
}
