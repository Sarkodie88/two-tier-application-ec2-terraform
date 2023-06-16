resource "aws_iam_role" "instance_profile_my_role" {
  name = var.instance_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = var.instance_role_name
  }
}

resource "aws_iam_role_policy_attachment" "my_role_policy_attachment_1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
  role       = aws_iam_role.instance_profile_my_role.name
}

resource "aws_iam_role_policy_attachment" "my_role_policy_attachment_2" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  role       = aws_iam_role.instance_profile_my_role.name
}

resource "aws_iam_role_policy_attachment" "my_role_policy_attachment_3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.instance_profile_my_role.name
}