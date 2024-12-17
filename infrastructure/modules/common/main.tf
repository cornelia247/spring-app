
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.env}-${var.project_name}-vpc"
    Project = var.project_name
    Environment  = var.env

  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name                                          = var.igw_name
    Environment                                           = var.env
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  depends_on = [aws_vpc.vpc]
}

resource "aws_subnet" "public_subnet" {
  count                   = var.pub_subnet_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.pub_cidr_block, count.index)
  availability_zone       = element(var.availability_zone, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name                                          = "${var.pub_sub_name}-${count.index + 1}"
    Project = var.project_name
    Environment  = var.env
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/elb"                      = "1"
  }

  depends_on = [aws_vpc.vpc,
  ]
}

resource "aws_subnet" "private_subnet" {
  count                   = var.pri_subnet_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.pri_cidr_block, count.index)
  availability_zone       = element(var.availability_zone, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name                                          = "${var.pri_sub_name}-${count.index + 1}"
    Project = var.project_name
    Environment  = var.env
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/internal_elb"             = "1"
  }

  depends_on = [aws_vpc.vpc,
  ]
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.public_rt_name
    Environment  = var.env
  }

  depends_on = [aws_vpc.vpc
  ]
}

resource "aws_route_table_association" "name" {
  count          = 2
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_subnet[count.index].id

  depends_on = [aws_vpc.vpc,
    aws_subnet.public_subnet
  ]
}

resource "aws_eip" "ngw_eip" {
  domain = "vpc"

  tags = {
    Name = var.eip_name
    Project = var.project_name
    Environment  = var.env
  }

  depends_on = [aws_vpc.vpc
  ]

}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = var.ngw_name
    Project = var.project_name
    Environment  = var.env
  }

  depends_on = [aws_vpc.vpc,
    aws_eip.ngw_eip
  ]
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = var.private_rt_name
    Project = var.project_name
    Environment  = var.env
  }

  depends_on = [aws_vpc.vpc,
  ]
}

resource "aws_route_table_association" "private_rt_association" {
  count          = 2
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private_subnet[count.index].id

  depends_on = [aws_vpc.vpc,
    aws_subnet.private_subnet
  ]
}

resource "aws_security_group" "db" {
  name        = "${var.env}-${var.project_name}-db-sg"
  description = "Allow specific traffic to database"

  vpc_id = aws_vpc.vpc.id

  # Allow HTTPS (Port 443)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow PostgreSQL (Port 5432) 
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.env}-${var.project_name}-db-sg"
    Project     = var.project_name
    Environment = var.env
  }
}

resource "aws_security_group" "lb" {
  name        = "${var.env}-${var.project_name}-lb-sg"
  description = "controls access to the ALB"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = var.app_port
    to_port     = var.app_port
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "${var.env}-${var.project_name}-lb-sg"
    Project     = var.project_name
    Environment = var.env
  }
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.env}-${var.project_name}-ecs-sg"
  description = "allow inbound access from the ALB only"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = var.app_port
    to_port         = var.app_port
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "${var.env}-${var.project_name}-ecs-sg"
    Project     = var.project_name
    Environment = var.env
  }
}
