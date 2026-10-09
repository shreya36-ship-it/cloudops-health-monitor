resource "aws_vpc" "main" {
  cidr_block       = "11.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Cloudops-VPC"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "11.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Cloudops-Public-Subnet-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "11.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Cloudops-Public-Subnet-2"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Cloudops-IGW"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Cloudops-Public-Route-Table"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "app" {
  name   = "cloudops-app-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Cloudops-App-SG"
  }
}
resource "aws_instance" "app_1" {
  ami           = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type = "t3.micro"
  key_name = "cloudops-key"

  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = <<-EOF
    #!/bin/bash

    dnf update -y
    dnf install -y docker git

    systemctl enable docker
    systemctl start docker

    cd /home/ec2-user

    git clone https://github.com/shreya36-ship-it/cloudops-health-monitor.git

    cd cloudops-health-monitor

    docker build -t cloudops-health-monitor .

    docker run -d \
      --name cloudops-monitor \
      --restart unless-stopped \
      -p 5000:5000 \
      cloudops-health-monitor
  EOF

  tags = {
    Name = "Cloudops-EC2-1"
  }
}

resource "aws_instance" "app_2" {
  ami           = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type = "t3.micro"
  key_name = "cloudops-key"

  subnet_id              = aws_subnet.public_2.id
  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = <<-EOF
    #!/bin/bash

    dnf update -y
    dnf install -y docker git

    systemctl enable docker
    systemctl start docker

    cd /home/ec2-user

    git clone https://github.com/shreya36-ship-it/cloudops-health-monitor.git

    cd cloudops-health-monitor

    docker build -t cloudops-health-monitor .

    docker run -d \
      --name cloudops-monitor \
      --restart unless-stopped \
      -p 5000:5000 \
      cloudops-health-monitor
  EOF

  tags = {
    Name = "Cloudops-EC2-2"
  }
}