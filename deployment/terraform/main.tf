# Production Infrastructure Definition for OrderFlow v2.3.0
# Transitioned from single EC2 instance (SPOF) to High-Availability Multi-AZ Container Infrastructure

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Production VPC for isolated workload execution
resource "aws_vpc" "orderflow_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "orderflow-prod-vpc"
    Environment = var.environment
    Version     = var.app_version
  }
}

# High-Availability Container Cluster (EKS / ECS Fargate Orchestration)
resource "aws_ecs_cluster" "orderflow_cluster" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "orderflow-prod-cluster"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
