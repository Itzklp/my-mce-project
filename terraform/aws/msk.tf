# --------------------------------------------------
# Amazon Managed Streaming for Apache Kafka (MSK)
# --------------------------------------------------

# Security Group for MSK brokers
resource "aws_security_group" "msk" {
  name        = "mce-msk-sg-${var.project_suffix}"
  description = "Security group for MSK brokers"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow Kafka clients to connect"
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict to your IP in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mce-msk-sg-${var.project_suffix}"
  }
}

# MSK cluster (fixed for AWS provider v5+)
resource "aws_msk_cluster" "kafka" {
  cluster_name           = "mce-msk-${var.project_suffix}"
  kafka_version          = "3.6.0"
  number_of_broker_nodes = 2

  broker_node_group_info {
    instance_type   = "kafka.t3.small" # cheaper for testing
    client_subnets  = aws_subnet.private[*].id
    security_groups = [aws_security_group.msk.id]

    storage_info {
      ebs_storage_info {
        volume_size = 20
      }
    }
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  tags = {
    Environment = "dev"
    Project     = "mce"
  }
}
