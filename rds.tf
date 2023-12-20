resource "aws_security_group" "rds" {
  name   = "supserset-rds"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "superset-rds"
  }
}

resource "aws_db_subnet_group" "superset" {
  name       = "superset"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "Superset"
  }
}

resource "aws_db_instance" "superset" {
  identifier             = "superset"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "16.1"
  db_name                = "superset"
  username               = "superset"
  password               = random_password.superset_postgresql_password.result
  db_subnet_group_name   = aws_db_subnet_group.superset.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.superset.name
  publicly_accessible    = true
  skip_final_snapshot    = true

    depends_on = [ random_password.superset_postgresql_password ]
}

resource "aws_db_parameter_group" "superset" {
  name   = "superset"
  family = "postgres16"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

# # Create Database 
# resource "postgresql_database" "superset" {
#     name              = "superset"
#     owner             = "superset"
#     template          = "template0"
#     lc_collate        = "C"
#     connection_limit  = -1
#     allow_connections = true

#     depends_on = [aws_db_instance.superset]
# }
