provider "aws" {
    access_key = "your access key"
    secret_key = "your-secret-key"
    region = "ap-south-1"
}

# create vpc
resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "MY_VPC"
    }
}
resource "aws_subnet" "my_app-subnet" {
     tags = {
        Name = "APP_Subnet"
    }
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    depends_on = [aws_vpc.my_vpc]
}
# RT
resource "aws_route_table" "my_route-table" {
    tags = {
        Name = "MY_Route_table"
    }
    vpc_id = aws_vpc.my_vpc.id
}

# associate subnet with RT
resource "aws_route_table_association" "App_Route_Association" {
    subnet_id = aws_subnet.my_app-subnet.id
    route_table_id = aws_route_table.my_route-table.id
}

# internet connectivity(IGW)
resource "aws_internet_gateway" "my_IG" {
    tags ={
        Name = "MY_IGW"
    }
    vpc_id = aws_vpc.my_vpc.id
    depends_on = [aws_vpc.my_vpc]
}

# default route in RT
resource "aws_route" "default_route" {
    route_table_id = aws_route_table.my_route-table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_IG.id
}
# SG
resource "aws_security_group" "App_SG" {
    name = "App_SG"
    description = "Allow inbound traffic"
    vpc_id = aws_vpc.my_vpc.id
    ingress {
        protocol = "tcp"
        from_port = 80
        to_port = 80
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        protocol = "tcp"
        from_port = 22
        to_port = 22
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        protocol = -1
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}

#  key-pair
# resource "tls_private_key" "web-key " {
#     algorithm = "RSA"
# }
resource "tls_private_key" "Web-Key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "App-Instance-Key" {
    key_name = "Web-Key"
    public_key = tls_private_key.Web-Key.public_key_openssh
}

resource "local_file" "Web-Key" {
    content = tls_private_key.Web-Key.private_key_pem
    filename = "Web-Key.pem"
}

# create ec2 instance
resource "aws_instance" "Web" {
    ami = "ami-03d3eec31be6ef6f9"
    instance_type = "t2.micro"
    tags = {
        Name = "WebServer1"
    }
    count =1
    subnet_id = aws_subnet.my_app-subnet.id
    key_name = "Web-Key"
    security_groups = [aws_security_group.App_SG.id]

    provisioner "remote-exec" {
        connection {
        type = "ssh"
        user = "ubuntu"
        private_key = tls_private_key.Web-Key.private_key_pem
        host = aws_instance.Web[0].public_ip
    }

    inline = [
        "sudo apt-get update",
        "sudo apt-get install -y apache2 git",
        "sudo systemctl restart apache2",
        "sudo systemctl enable apache2",
        "sudo mkdir app",
        "sudo cd app",
        "sudo git clone https://github.com/priyanka-1994/fresko-lab.git"
        ]
    }
}

resource "aws_s3_bucket" "flexo-demo-bucket" {
    bucket = "flexo-demo-bucket"
    acl = "public-read"
    #region = "ap-south-1"
    # versioning {
    #     enabled = true
    # }
    tags = {
        Name = "flexo-demo-bucket"
    }
    provisioner "local-exec" {
        command = "git clone https://github.com/priyanka-1994/fresko-lab.git"
    }
}
# allow public access
resource "aws_s3_bucket_public_access_block" "public_storage"{
    depends_on = [aws_s3_bucket.flexo-demo-bucket]
    bucket = "flexo-demo-bucket"
    block_public_acls = false
    block_public_policy = false
}
# upload object
resource "aws_s3_bucket_object" "object1" {
    depends_on = [aws_s3_bucket.flexo-demo-bucket]
    bucket = "flexo-demo-bucket"
    acl = "public-read"
    key = "index.html"
    #source = "app/template/index.html"
}
