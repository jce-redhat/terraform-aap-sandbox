output "instances" {
  description = "Map of instance keys to instance details"
  value = {
    for k, v in aws_instance.aap : k => {
      id           = v.id
      private_ip   = v.private_ip
      public_ip    = v.public_ip
      name         = v.tags["Name"]
      node_type    = v.tags["NodeType"]
      instance_key = v.tags["InstanceKey"]
    }
  }
}

output "eips" {
  description = "Map of instance keys to Elastic IP addresses"
  value = {
    for k, v in aws_eip.aap : k => {
      public_ip   = v.public_ip
      instance_id = v.instance
    }
  }
}

output "instances_by_node_type" {
  description = "Map of node types to lists of instance keys"
  value = {
    for node_type in distinct([for k, v in aws_instance.aap : v.tags["NodeType"]]) :
    node_type => [
      for k, v in aws_instance.aap : k if v.tags["NodeType"] == node_type
    ]
  }
}

output "instance_names" {
  description = "Map of instance keys to DNS-friendly names"
  value = {
    for k, v in aws_instance.aap : k => v.tags["Name"]
  }
}
