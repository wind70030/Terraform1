
## 퍼블릭 보안 그룹
resource "aws_security_group" "Public-SG" {
  vpc_id = module.vpc.vpc_id
  name = "public SG"
  description = "public SG"
  tags = {
    Name = "public SG"
  }
}
## 프라이빗 보안 그룹
resource "aws_security_group" "Private-SG" {
  vpc_id = module.vpc.vpc_id
  name = "private SG"
  description = "private SG"
  tags = {
    Name = "private SG"
  }
}
## 퍼블릭 보안 그룹 규칙
resource "aws_security_group_rule" "PublicSGRulesHTTPingress" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "TCP"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.Public-SG.id
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "PublicSGRulesHTTPegress" {
  type = "egress"
  from_port = 80
  to_port = 80
  protocol = "TCP"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.Public-SG.id
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "PublicSGRulesHTTPSingress" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "TCP"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.Public-SG.id
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "PublicSGRulesHTTPSegress" {
  type = "egress"
  from_port = 443
  to_port = 443
  protocol = "TCP"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.Public-SG.id
  lifecycle {
    create_before_destroy = true
  }
}
/* resource "aws_security_group_rule" "blogPublicSGRulesSSHingress" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "TCP"
  cidr_blocks = [ "---.---.---.---/32" ]
  security_group_id = aws_security_group.blogPublicSG.id
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "blogPublicSGRulesSSHegress" {
  type = "egress"
  from_port = 22
  to_port = 22
  protocol = "TCP"
  cidr_blocks = [ "---.---.---.---/32" ]
  security_group_id = aws_security_group.blogPublicSG.id
  lifecycle {
    create_before_destroy = true
  }
} */
### Private Security Group rules
resource "aws_security_group_rule" "PrivateSGRulesRDSingress" {
  type = "ingress"
  from_port = 3306
  to_port = 3306
  protocol = "TCP"
  security_group_id = aws_security_group.Private-SG.id
  source_security_group_id = aws_security_group.Public-SG.id
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "PrivateSGRulesRDSegress" {
  type = "egress"
  from_port = 3306
  to_port = 3306
  protocol = "TCP"
  security_group_id = aws_security_group.Private-SG.id
  source_security_group_id = aws_security_group.Public-SG.id
  lifecycle {
    create_before_destroy = true
  }
}
