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
  name               = "aap_instance_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_aap_instance_role.json
}

resource "aws_iam_role_policy_attachment" "ec2_read_only" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "aap_instance_profile" {
  name = "aap_instance_profile"
  role = aws_iam_role.role.name
}
