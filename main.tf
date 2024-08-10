provider "aws" {
  region = "sa-east-1"
}

# Criar uma nova VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "MainVPC"
  }
}

# Criar uma subnet pública
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "sa-east-1a"

  tags = {
    Name = "PublicSubnet"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main_vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "main_subnet"
  }
}

resource "aws_security_group" "allow_ssh_http" {
  vpc_id = aws_vpc.main.id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_http"
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id
  security_groups = [aws_security_group.allow_ssh_http.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              sudo curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose
              sudo yum install -y git
              git clone https://github.com/lvgalvao/stremlit-deploy-terraform /home/ec2-user/app
              cd /home/ec2-user/app
              sudo docker build -t streamlit-app .
              sudo docker run -d -p 80:80 streamlit-app
              EOF

  tags = {
    Name = "web_instance"
  }
}

output "instance_public_ip" {
  value = aws_instance.web.public_ip
}

# Criar uma instância EC2
resource "aws_instance" "example" {
  ami           = "ami-09523541dfaa61c85" # Substitua pela AMI do Amazon Linux desejada
  instance_type = "t2.micro"              # Tipo da instância
  subnet_id     = aws_subnet.public.id

  security_groups = [aws_security_group.allow_ssh_http.name]

  user_data = <<-EOF
              #!/bin/bash
              # Atualizar o sistema
              sudo yum install -y docker
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              sudo curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose

              sudo yum install -y git
              # Clonar o repositório Git
              git clone https://github.com/lvgalvao/streamlit-app-docker.git /home/ec2-user/streamlit-app-docker
              
              # Navegar para o diretório clonado
              cd /home/ec2-user/streamlit-app-docker

              # Construir a imagem docker
              sudo docker build -t streamlit-app-docker .

              # Rodar a imagem
              sudo docker run -p 80:80 streamlit-app-docker

              EOF

  tags = {
    Name = "MyEC2Instance_stramlit"
  }
}
