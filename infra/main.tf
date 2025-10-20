provider "aws" {
  region = var.aws_region
}

# Criar bucket S3
resource "aws_s3_bucket" "lab" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.lab.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Gerar par de chaves AWS e salvar a privada localmente
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content        = tls_private_key.ec2_key.private_key_pem
  filename       = "infra/ec2_key.pem"
  file_permission = "0400"   # garante permissões corretas
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "ec2_key"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

# Criar instância EC2 com a chave gerada
resource "aws_instance" "app_server" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 (us-east-1)
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ec2_key.key_name

  tags = {
    Name = "Sprint5-EC2"
  }
}

# Outputs
output "bucket_name" {
  value = aws_s3_bucket.lab.bucket
}

output "ec2_public_ip" {
  value = aws_instance.app_server.public_ip
}

output "private_key_path" {
  value = local_file.private_key.filename
}
