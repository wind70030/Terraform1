#rds의 서브넷 그룹으로 사용할 subnet들 미리 지정

resource "aws_db_subnet_group" "realDBSubnetGroup" {
  name = "db_subnet_group"
  subnet_ids = module.vpc.database_subnets
  tags = {
    "Name" = "db-subnet-group"
  }
}

resource "aws_db_instance" "database" { 
    allocated_storage = 50
    max_allocated_storage = 80
    skip_final_snapshot = true
#보안그룹 지정.
    vpc_security_group_ids = [aws_security_group.DB-SG.id ]
#서브넷 그룹 지정.
    db_subnet_group_name = "${aws_db_subnet_group.realDBSubnetGroup.id}"
    publicly_accessible = false
    engine = "mariadb"
    engine_version = "10.6.8"
    instance_class = "db.t3.small"
    /* multi_az = true
    availability_zone = "ap-northeast-2a" */
    identifier = "test-rdb"
    name = "testRDB"
    username = "admin"
    password = "testtest"
    tags = {
        "Name" = "realDB"
    }
}
