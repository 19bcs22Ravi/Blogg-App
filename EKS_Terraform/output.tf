output "cluster_id" {
  value = aws_eks_cluster.bloggapp.id
}

output "node_group_id" {
  value = aws_eks_node_group.bloggapp.id
}

output "vpc_id" {
  value = aws_vpc.bloggapp_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.bloggapp_subnet[*].id
}
