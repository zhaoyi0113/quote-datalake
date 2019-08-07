resource "aws_iam_policy" "s3_policy" {
  name   = "s3_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": "s3:*",
        "Resource": [
            "arn:aws:s3:::${var.s3_bucket}",
            "arn:aws:s3:::${var.s3_bucket}/*"
        ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "athena_policy" {
  name = "athena_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "athena:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    } 
  ]
}
EOF
}

resource "aws_iam_policy" "glue_policy" {
    name   = "glue_access_policy"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "glue:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

#Created Policy for IAM Role
resource "aws_iam_policy" "iam_policy" {
  name = "lambda_access-policy"
  description = "IAM Policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:GetBucketLocation"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.s3_bucket}",
                "arn:aws:s3:::${var.s3_bucket}/*"
            ]
        },
        {
          "Action": [
            "autoscaling:Describe*",
            "cloudwatch:*",
            "logs:*",
            "sns:*"
          ],
          "Effect": "Allow",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
           "ssm:DescribeParameters",
           "ssm:GetParameters",
           "ssm:GetParameter",
           "ssm:GetParametersByPath"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
           "kms:*"
          ],
          "Resource": "*"
        }
  ]
}
  EOF
}
