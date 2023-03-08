variable "aws_access_key" {
    default = ""
}

variable "aws_secret_key" {
    default = ""
}


provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "eu-central-1"
}

resource "aws_instance" "web_server" {
    count = 2
    ami = "ami-0d1ddd83282187d18"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.web_server.id]
    user_data = <<EOF
#!/bin/bash
sudo apt -y update
sudo apt -y install apache2
myip=ʼcurl http://169.254.169.254/latest/meta-data/local-ipv4ʼ
echo "<h2>WebServer with ip: $myip</h2><br>Build and run by Terraform!" > /var/www/html/index.html
sudo systemctl restart apache2
sudo systemctl enable apache2
EOF

    tags = {
        "Name" = "WebServer"
        "Owner" = "Ihor Zinchenko"
    }
}

resource "aws_security_group" "web_server" {
    name = "WebServer Security Group"
    description = "Security group with access to WebServer ports"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
  
}
