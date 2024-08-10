provider "aws" {
  region = "sa-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0" # Substitua pela AMI do Amazon Linux desejada
  instance_type = "t2.micro"              # Tipo da instância

  user_data = <<-EOF
              #!/bin/bash
              # Atualizar o sistema
              sudo dnf update -y
              
              # Instalar Git
              sudo dnf install git -y
              
              # Clonar o repositório Git
              git clone https://github.com/lvgalvao/streamlit-app-docker.git /home/ec2-user/streamlit-app-docker
              
              # Instalar Docker
              sudo dnf install docker -y
              
              # Iniciar e habilitar Docker
              sudo systemctl start docker
              sudo systemctl enable docker
              
              # Adicionar o usuário ec2-user ao grupo Docker
              sudo usermod -aG docker ec2-user
              
              # Navegar para o diretório clonado
              cd /home/ec2-user/streamlit-app-docker
              EOF

  tags = {
    Name = "MyEC2Instance"
  }
}
