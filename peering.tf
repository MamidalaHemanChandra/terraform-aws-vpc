resource "aws_vpc_peering_connection" "roboshop" {
  count = var.peering_required ? 1 : 0
  peer_vpc_id   = data.aws_vpc.default.id 
  vpc_id        = aws_vpc.main.id 

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  auto_accept   = true

  tags = merge(
    var.peering_tags,
    local.common_tags,
    {
      Name = "${local.common_name}"
    }
  )
}

resource "aws_route" "public" {
    count = var.peering_required ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.roboshop[0].id
}

resource "aws_route" "default" {
    count = var.peering_required ? 1 : 0
  route_table_id            = data.aws_route_table.default.id
  destination_cidr_block    = var.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.roboshop[0].id
}
