provider "aws" {
  region = "eu-north-1" # Change to your preferred region

}

# -----------------------------------------
# IAM Role for Elastic Beanstalk
# -----------------------------------------
resource "aws_iam_role" "eb_role" {
  name = "aws-elasticbeanstalk-ec2-final-role"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach necessary policies
resource "aws_iam_role_policy_attachment" "eb_policy" {
  role       = aws_iam_role.eb_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_instance_profile" "eb_instance_profile" {
  name = "aws-elasticbeanstalk-ec2-profile-final-dev"
  role = aws_iam_role.eb_role.name
}

# -----------------------------------------
# Elastic Beanstalk Application
# -----------------------------------------
resource "aws_elastic_beanstalk_application" "my_app" {
  name        = "express-backend"
  description = "Elastic Beanstalk application with auto-scaling"
}

# -----------------------------------------
# Elastic Beanstalk Environment
# -----------------------------------------
resource "aws_elastic_beanstalk_environment" "my_env" {
  name                = "express-backend-env"
  application         = aws_elastic_beanstalk_application.my_app.name
  solution_stack_name = "64bit Amazon Linux 2023 v6.4.3 running Node.js 22" # Adjust this for your language

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.eb_instance_profile.name
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "1"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "5"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "CrossZone"
    value     = "true"
  }
}
