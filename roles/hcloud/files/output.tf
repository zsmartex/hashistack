output "sre_server" {
  value = one(flatten([
    for index, node in hcloud_server.server_node : [
      for server in local.servers :
      {host = "${node.ipv4_address}", 
        host_name = "${node.name}", 
        private_ip = "${server.private_ip}",
        server_id= node.id
      } if server.name == node.name
    ] if node.labels["group"] == "sre"
  ]))
}

output "consul_servers" {
  value = flatten([
    for index, node in hcloud_server.server_node : [
      for server in local.servers :
      {host = "${node.ipv4_address}", 
        host_name = "${node.name}", 
        private_ip = "${server.private_ip}",
        server_id= node.id
        volumes = flatten([
          for index, attachment in hcloud_volume_attachment.consul : [
            {mount_path = "/mnt/HC_Volume_${attachment.volume_id}", 
            path = "/opt/consul",
            name = "",
            owner = "consul",
            group = "consul",
            server_id = attachment.server_id,
            is_nomad = false
            }
          ] if tonumber(node.id) == attachment.server_id
        ])
      } if server.name == node.name
    ] if node.labels["group"] == "consul"
  ])
}


output "nomad_servers" {
  value = flatten([
    for index, node in hcloud_server.server_node : [
      for server in local.servers :
      {host = "${node.ipv4_address}", 
        host_name = "${node.name}", 
        private_ip = "${server.private_ip}",
        server_id = node.id
        volumes = flatten([
          for index, attachment in hcloud_volume_attachment.consul : [
            {mount_path = "/mnt/HC_Volume_${attachment.volume_id}", 
            path = "/opt/consul",
            name = "",
            owner = "consul",
            group = "consul",
            server_id = attachment.server_id,
            is_nomad = false
            }
          ] if tonumber(node.id) == attachment.server_id
        ])
      } if server.name == node.name
    ] if node.labels["group"] == "nomad-server"
  ])
}

output "vault_servers" {
  value = flatten([
    for index, node in hcloud_server.server_node : [
      for server in local.servers :
      {host = "${node.ipv4_address}",
        host_name = "${node.name}", 
        private_ip = "${server.private_ip}",
        server_id= node.id
        volumes = flatten([
          for index, attachment in hcloud_volume_attachment.vault : [
            {mount_path = "/mnt/HC_Volume_${attachment.volume_id}", 
            path = "/opt/vault",
            name = "",
            owner = "vault",
            group = "vault",
            server_id = attachment.server_id,
            is_nomad = false
            }
          ] if tonumber(node.id) == attachment.server_id
        ])
      } if server.name == node.name
    ] if node.labels["group"] == "vault"
  ])
}

output "client_servers" {
  value = flatten([
    for index, node in hcloud_server.server_node : [
      for server in local.servers :
      {host = "${node.ipv4_address}", 
        host_name = "${node.name}", 
        private_ip = "${server.private_ip}",
        server_id = node.id
        volumes = flatten([
          for index, attachment in hcloud_volume_attachment.client_volumes : [
            for vol in var.client_volumes :
            {mount_path = "/mnt/HC_Volume_${attachment.volume_id}", 
            path = vol.path,
            name = vol.name,
            is_nomad = true,
            owner = coalesce(vol.owner, "root"),
            group = coalesce(vol.group, "root"),
            server_id = attachment.server_id} if hcloud_volume.client_volumes[index].name == vol.name
          ] if tonumber(node.id) == attachment.server_id
        ])
      } if server.name == node.name
    ] if node.labels["group"] == "client"
  ])
}

output "observability_servers" {
  value = flatten([
    for index, node in hcloud_server.server_node : [
      for server in local.servers :
      {host = "${node.ipv4_address}", 
        host_name = "${node.name}", 
        private_ip = "${server.private_ip}",
        server_id = node.id
      } if server.name == node.name
     ] if node.labels["group"] == "observability"
  ])
}
