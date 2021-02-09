data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.PUBLIC_KEY
}

resource "aws_instance" "bastion-host-1" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.deployer.key_name
  availability_zone           = var.AWS_PUBLIC_AZ
  subnet_id                   = aws_subnet.wl-public.id
  vpc_security_group_ids      = [aws_security_group.allow_ssh_http_https.id]
  associate_public_ip_address = true
  tags = {
    Name  = "bastion-host-1"
    Group = "bastion"
  }
  depends_on = [aws_internet_gateway.igw]

  provisioner "file" {
    source      = var.PRIVATE_KEY_FILE
    destination = "~/.ssh/id_rsa"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.PRIVATE_KEY_FILE)
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = ["chmod 600 ~/.ssh/id_rsa"]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.PRIVATE_KEY_FILE)
      host        = self.public_ip
    }
  }
}

resource "aws_launch_template" "wl" {
    name                         = "wl-template"
    image_id                     = data.aws_ami.amazon_linux.id
    instance_type                = "t3.medium"
    key_name                    = aws_key_pair.deployer.key_name
    network_interfaces {
      subnet_id = aws_subnet.wl-carrier.id
      associate_carrier_ip_address = true
      security_groups = [aws_security_group.allow_ssh_http_https.id]
    }
}

resource "aws_autoscaling_group" "wl-host" {
  max_size                     = 1
  min_size                     = 1
  desired_capacity             = 1
  availability_zones           = [var.AWS_WL_AZ]

  tag {
    key                 = "Group"
    value               = "wavelength"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "wl-host"
    propagate_at_launch = true
  }

  launch_template {
      id      = aws_launch_template.wl.id
      version = "$Latest"
  }
  depends_on = [aws_ec2_carrier_gateway.cgw]
}
