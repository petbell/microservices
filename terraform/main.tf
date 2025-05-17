terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=5.97"
    }
  }
  required_version = "1.12.0"
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_vpc" "mirovpc" {
  cidr_block         = "10.0.0.0/16"
  enable_dns_support = true
}

resource "aws_subnet" "micropublic_subnet" {
  vpc_id                  = aws_vpc.mirovpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "micropublic_subnet"
  }
}

resource "aws_subnet" "microprivate_subnet" {
  vpc_id                  = aws_vpc.mirovpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "microprivate_subnet"
  }
}
resource "aws_internet_gateway" "miroigw" {
  vpc_id = aws_vpc.mirovpc.id
  tags = {
    Name = "miroigw"
  }
}

resource "aws_route_table" "micropublic_route_table" {
  vpc_id = aws_vpc.mirovpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.miroigw.id
  }
}

resource "aws_eip" "microelastic_ip" {

  tags = {
    Name = "microelastic_ip"
  }
}
resource "aws_nat_gateway" "micronat_gateway" {
  allocation_id = aws_eip.microelastic_ip.id
  subnet_id     = aws_subnet.micropublic_subnet.id
  depends_on    = [aws_internet_gateway.miroigw]
  tags = {
    Name = "micronat_gateway"
  }
}

resource "aws_route_table" "microprivate_route_table" {
  vpc_id = aws_vpc.mirovpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.micronat_gateway.id
  }
  tags = {
    Name = "microprivate_route_table"
  }
}

resource "aws_route_table_association" "micropublic_association" {
  subnet_id      = aws_subnet.micropublic_subnet.id
  route_table_id = aws_route_table.micropublic_route_table.id

}

resource "aws_route_table_association" "microprivate_association" {
  subnet_id      = aws_subnet.microprivate_subnet.id
  route_table_id = aws_route_table.microprivate_route_table.id
}

resource "aws_security_group" "micropublic_sg" {
  vpc_id      = aws_vpc.mirovpc.id
  name        = "microsecuritygroup"
  description = "Allow SSH, Postgresql and HTTP inbound traffic"
  tags = {
    Name = "microsecuritygroup"
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "microprivate_sg" {
  vpc_id      = aws_vpc.mirovpc.id
  name        = "microprivate_sg"
  description = "Allow SSH  inbound traffic"
  tags = {
    Name = "microprivate_sg"
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "microec2_server" {
  ami                    = "ami-0105b7fc0041ff22b"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.micropublic_subnet.id
  vpc_security_group_ids = [aws_security_group.micropublic_sg.id]
  key_name               = "gmailAWS"
  tags = {
    Name = "microec2"
  }
  
  user_data = <<-EOF
              #!/bin/bash
              # udate the package index
              sudo apt update -y
              # install docker, curl and git
              sudo apt install -y docker.io git curl
              # start docker and enable it to start on boot
              sudo systemctl start docker
              sudo systemctl enable docker
              
              # sudo usermod -aG docker ubuntu
              # delay for 10 seconds to ensure docker is up
              sleep 10

              # Install docker-compose
              sudo curl -SL https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose
              #clone the repo and start the docker containers
              git clone --single-branch --branch nginx https://github.com/petbell/microservices.git
              cd microservices
              sudo docker-compose up -d
              sudo docker ps
              EOF
}

resource "aws_instance" "microec2_prometheus" {
  ami                    = "ami-0105b7fc0041ff22b"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.micropublic_subnet.id
  vpc_security_group_ids = [aws_security_group.micropublic_sg.id]
  key_name               = "gmailAWS"
  tags = {
    Name = "microec2_prometheus"
  }

}

output "show_server_ip" {
  value       = aws_instance.microec2_server.public_ip
  description = "value of the public IP address of the server"
}
output "show_prometheus_ip" {
  value       = aws_instance.microec2_prometheus.public_ip
  description = "value of the public IP address of the prometheus server"
}