# RDS DB Cluster 생성
resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier = "rds-cluster"
  # db_subnet_group_name   = "${aws_db_subnet_group.realDBSubnetGroup.id}"
  db_subnet_group_name   = local.eks_cluster_name
  vpc_security_group_ids = [aws_security_group.DB-SG.id]
  engine = "aurora-mysql"
  engine_version = "5.7.mysql_aurora.2.11.1"
  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[2]]
  database_name = "mytestdb"
  master_username = "admin"
  master_password = "testtest"
  skip_final_snapshot = true
  apply_immediately    = true
}

  
# rds cluster의 writer 인스턴스 endpoint 추출
# (mysql 설정 및 Three-tier 연동파일에 정보 입력 필요해서 추출)
output "rds_writer_endpoint" { 
  value = aws_rds_cluster.rds_cluster.endpoint
  # 해당 추출값은 terraform apply 완료 시 또는 terraform output rds_writer_endpoint로 확인 가능
}

resource "aws_rds_cluster_instance" "aurora-mysql-db-instance" {
  count = 2 # RDS Cluster에 속한 총 2개의 DB 인스턴스 생성 (Reader/Writer로 지정)
  identifier = "rds-cluster-${count.index}" # Instance의 식별자명 (count index로 0번부터 1씩 상승)
  cluster_identifier = aws_rds_cluster.rds_cluster.id # 소속될 Cluster의 ID 지정
  instance_class = "db.t3.small" # DB 인스턴스 Class (메모리 최적화/버스터블 클래스 선택 없이 type명만 적으면 됌)
  engine = "aurora-mysql"
  engine_version = "5.7.mysql_aurora.2.11.1"
}
