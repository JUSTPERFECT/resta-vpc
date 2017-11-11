
## VPC creation for app

resource "aws_vpc" "restarent_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "dedicated"
  enable_dns_hostnames = true
  tags {
    Name  = "restarent_vpc"
    owner = "jayaprakash"
    team  =" web app migration team"
  }
}


## public subnet creation in Az1

resource "aws_subnet" "restarent_public_subnet_1a" {
  vpc_id     = "${aws_vpc.restarent_vpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-southeast-1a"
  map_public_ip_on_launch = true
  tags {
    Name = "restarent_public_subnet_1a"
    owner = "jayaprakash"
    team  =" web app migration team"
  }
}


## public subnet creation in Az2

resource "aws_subnet" "restarent_public_subnet_1b" {
  vpc_id     = "${aws_vpc.restarent_vpc.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-southeast-1b"
  map_public_ip_on_launch = true
  tags {
    Name = "restarent_public_subnet_1b"
    owner = "jayaprakash"
    team  =" web app migration team"
  }
}



## private subnet creation in Az1

resource "aws_subnet" "restarent_private_subnet_1a" {
  vpc_id     = "${aws_vpc.restarent_vpc.id}"
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-southeast-1a"
  map_public_ip_on_launch = false
  tags {
    Name = "restarent_private_subnet_1a"
    owner = "jayaprakash"
    team  =" web app migration team"
  }
}


## private subnet creation in Az2

resource "aws_subnet" "restarent_private_subnet_1b" {
  vpc_id     = "${aws_vpc.restarent_vpc.id}"
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-southeast-1b"
  map_public_ip_on_launch = false
  tags {
    Name = "restarent_private_subnet_1b"
    owner = "jayaprakash"
    team  =" web app migration team"
  }
}



## internet gateway for restarent_vpc

resource "aws_internet_gateway" "restarent_internet_gateway" {
  vpc_id = "${aws_vpc.restarent_vpc.id}"

  tags {
    Name = "restarent_internet_gateway"
    owner = "jayaprakash"
    team  =" web app migration team"
  }
}

## elastic IP creation

resource "aws_eip" "restarent_nat_eip" {
  vpc      = true
}



## Nat gateway creation

resource "aws_nat_gateway" "restarent_nat_gateway" {
  allocation_id = "${aws_eip.restarent_nat_eip.id}"
  subnet_id     = "${aws_subnet.restarent_public_subnet_1a.id}"
}

## route table for public Subnets


resource "aws_route_table" "restarent_public_route_table" {
  vpc_id = "${aws_vpc.restarent_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.restarent_internet_gateway.id}"
  }

  tags {
    Name = "restarent_public_route_table"
    owner = "jayaprakash"
    team  =" web app migration team"
  }
}


## route table for private Subnets


resource "aws_route_table" "restarent_private_route_table" {
  vpc_id = "${aws_vpc.restarent_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.restarent_nat_gateway.id}"
  }
  tags {
    Name = "restarent_private_route_table"
    owner = "jayaprakash"
    team  =" web app migration team"
  }

}


## Associate public subnet AZ1 with public route table

resource "aws_route_table_association" "restarent_public_1a_association" {
  subnet_id      = "${aws_subnet.restarent_public_subnet_1a.id}"
  route_table_id = "${aws_route_table.restarent_public_route_table.id}"
}

## Associate public subnet AZ2 with public route table

resource "aws_route_table_association" "restarent_public_1b_association" {
  subnet_id      = "${aws_subnet.restarent_public_subnet_1b.id}"
  route_table_id = "${aws_route_table.restarent_public_route_table.id}"
}



## Associate private subnet AZ1 with private route table

resource "aws_route_table_association" "restarent_private_1a_association" {
  subnet_id      = "${aws_subnet.restarent_private_subnet_1a.id}"
  route_table_id = "${aws_route_table.restarent_private_route_table.id}"
}

## Associate private subnet AZ2 with private route table

resource "aws_route_table_association" "restarent_private_1b_association" {
  subnet_id      = "${aws_subnet.restarent_private_subnet_1b.id}"
  route_table_id = "${aws_route_table.restarent_private_route_table.id}"
}


## NACL for public subnet

resource "aws_network_acl" "restarent_public_nacl" {
  vpc_id = "${aws_vpc.restarent_vpc.id}"
 subnet_ids= ["${aws_subnet.restarent_public_subnet_1a},${aws_subnet.restarent_public_subnet_1b}"]
  egress {
     protocol   = "-1"
     rule_no    = 100
     action     = "allow"
     cidr_block = "0.0.0.0/0"
     from_port  = -1
     to_port    = -1
   }
   ingress {
      protocol   = "-1"
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = -1
      to_port    = -1
    }
   ingress {
     protocol   = "-1"
     rule_no    = 200
     action     = "allow"
     cidr_block = "0.0.0.0/0"
     from_port  = 32768
     to_port    = 61000
   }

  }


## NACL for private subnet

resource "aws_network_acl" "restarent_private_nacl" {
  vpc_id = "${aws_vpc.restarent_vpc.id}"
 subnet_ids= ["${aws_subnet.restarent_private_subnet_1a},${aws_subnet.restarent_private_subnet_1b}"]
  egress {
     protocol   = "-1"
     rule_no    = 100
     action     = "allow"
     cidr_block = "0.0.0.0/0"
     from_port  = -1
     to_port    = -1
   }
   ingress {
      protocol   = "-1"
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = -1
      to_port    = -1
    }
   ingress {
     protocol   = "-1"
     rule_no    = 200
     action     = "allow"
     cidr_block = "0.0.0.0/0"
     from_port  = 32768
     to_port    = 61000
   }
}

## Hosted zone for restarent web site

resource "aws_route53_zone" "restarent_route53_zone" {
  name = "serverless-iot.com"
  tags {
    Name = "restarent_route53_zone"
    owner = "jayaprakash"
    team  =" web app migration team"
  }
}
