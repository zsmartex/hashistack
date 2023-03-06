locals {
  instance_image             = "debian-11"
  consul_group = var.separate_consul_servers ? "consul" : "nomad-server"
  groups = {
    sre = {
      count = "1", subnet = "0", group = 0, server_type = var.server_instance_type
    },
    bootstrap = {
      count = var.bootstrap_count, subnet = "1", group = 1, server_type = var.server_instance_type
    },
    consul = {
      count = var.separate_consul_servers ? var.server_count : 0 * var.server_count,
      subnet = "2", group = 1, server_type = var.server_instance_type
    },
    nomad-server = {
      count = var.server_count, subnet = "3", group = 1, server_type = var.server_instance_type
    },
    vault = {
      count = var.vault_count, subnet = "4", group = 1, server_type = var.server_instance_type
    },
    client = {
      count = var.client_count, subnet = "5", group = 2, server_type = var.client_instance_type
    },
    observability = {
      count = var.multi_instance_observability ? 4 : 1, subnet = "6", group = 1, server_type = var.observability_instance_type
    }
  }

  servers = flatten([
    for name, value in local.groups : [
      for i in range(value.count) : {
        group_name = name,
        private_ip = "10.0.${value.subnet}.${i + 2}",
        name       = "${var.base_server_name}-${name}-${i + 1}",
        group      = value.group
        index = i
        server_type = value.server_type
      }
    ]
  ])

  placement_groups = 3
}

# Create a new SSH key
resource "hcloud_ssh_key" "admin" {
  name       = "${var.base_server_name}_key"
  public_key = trimspace(file(var.ssh_public_key_file))
}

resource "hcloud_uploaded_certificate" "certificate" {
  name        = "certificate"
  certificate = <<-EOT
  -----BEGIN CERTIFICATE-----
  MIIGOzCCBSOgAwIBAgIMS+4BB2bl2pcyJiHAMA0GCSqGSIb3DQEBCwUAMEwxCzAJ
  BgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMSIwIAYDVQQDExlB
  bHBoYVNTTCBDQSAtIFNIQTI1NiAtIEcyMB4XDTIyMDUzMDE2MDAxMVoXDTIzMDcw
  MTE2MDAxMFowGTEXMBUGA1UEAwwOKi56c21hcnRleC5jb20wggEiMA0GCSqGSIb3
  DQEBAQUAA4IBDwAwggEKAoIBAQD5QsuEGzXbuHnMA2ycUmXm32l5ohU7/9YhL79D
  QmhQgNrjTVR+3K7KfFCq5BqcUoY12jClBZTOwjofHjtjK1qDIXBDIpynuVToMA4K
  NAqFVgzOXoalLy8i8bnU9oNAWWkLBmJ98o8Fg4DVFvxiCfUciXookQCnvvj2TqoO
  UPWc6PtJ9ZAIS0yeAVcqQ6p5Ah6jMXmvHnsDF8uPS8YYaEQ5k+UEYgkdj/xY1eHE
  jCCOWkOyIB13aarwI3qwNlQc/cM9sqKEBqKuk9G0A4lbQR00k8xsDAxpD4HKBPZ5
  2/HKp5+cjTY5WnPAvGw5w+HAELFbg0tT+cU3Jsm9jz+jO6s3AgMBAAGjggNOMIID
  SjAOBgNVHQ8BAf8EBAMCBaAwgYoGCCsGAQUFBwEBBH4wfDBDBggrBgEFBQcwAoY3
  aHR0cDovL3NlY3VyZS5nbG9iYWxzaWduLmNvbS9jYWNlcnQvZ3NhbHBoYXNoYTJn
  MnIxLmNydDA1BggrBgEFBQcwAYYpaHR0cDovL29jc3AyLmdsb2JhbHNpZ24uY29t
  L2dzYWxwaGFzaGEyZzIwVwYDVR0gBFAwTjBCBgorBgEEAaAyAQoKMDQwMgYIKwYB
  BQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3JlcG9zaXRvcnkvMAgG
  BmeBDAECATAJBgNVHRMEAjAAMD8GA1UdHwQ4MDYwNKAyoDCGLmh0dHA6Ly9jcmwu
  Z2xvYmFsc2lnbi5jb20vZ3MvZ3NhbHBoYXNoYTJnMi5jcmwwJwYDVR0RBCAwHoIO
  Ki56c21hcnRleC5jb22CDHpzbWFydGV4LmNvbTAdBgNVHSUEFjAUBggrBgEFBQcD
  AQYIKwYBBQUHAwIwHwYDVR0jBBgwFoAU9c3VPAhQ+WpPOreX2laD5mnSaPcwHQYD
  VR0OBBYEFPjYcQ+usjCDA+oTo6T0TSFzJjyyMIIBfAYKKwYBBAHWeQIEAgSCAWwE
  ggFoAWYAdgDoPtDaPvUGNTLnVyi8iWvJA9PL0RFr7Otp4Xd9bQa9bgAAAYEVskA4
  AAAEAwBHMEUCIDPjhQwz3xHjjY85TOw9DCViI7H6tPLDOmFGAZAx/yO3AiEA/kol
  LUuxmwd7ovZVZBSv4uIhmOJCyjjEkG4SUUMJ+wMAdQBvU3asMfAxGdiZAKRRFf93
  FRwR2QLBACkGjbIImjfZEwAAAYEVskAsAAAEAwBGMEQCICuB2UObxBUHsqR9o4UH
  nx+ZT5isi4YINUjEdVQYSOugAiBx53XqS/oMrvCLxSMfZwV03yYvOoYAB6AS+0KT
  zq/QpQB1AFWB1MIWkDYBSuoLm1c8U/DA5Dh4cCUIFy+jqh0HE9MMAAABgRWyQE0A
  AAQDAEYwRAIgMtmKBMYGxKKFWaz22YfQJ0bSW8YGFlwNcW1GNYGVhEQCICc362LG
  P54MdhC4HrevsptJIPHqYPOPwF0mEIW1tuAWMA0GCSqGSIb3DQEBCwUAA4IBAQAQ
  +DGy2XM89RgvyUHqMyXt+A9T1dxGEGpPfh7pXradqiiY6IE5l00mrIgzckEOJJeN
  OJFrR3KCnQG5/Ct8ydJP2/Ez0mVWtvSK8h+FXnfr9FaJClvu71uqAU1ytWZ8FFhK
  xyjF6+5K5VCWklZdUbego30mMspzETT5dUcSeXnKY8bRBGF1dCmQDDQSWacEBDac
  DyM24dFQ1LEpqP8fFeZhC55gmMSxrNlnf8mdLGX6x1vIpUIPDsiaJHJbblM5J3IN
  3mqBdUanH9B+lfcVWivfentnl6/7CBIc+7+3BinJzx2EDLnnadfz4DwaJX/ypIKs
  SFgHx2Bsj877cwYA/RD7
  -----END CERTIFICATE-----
  EOT
  private_key = <<-EOT
  -----BEGIN PRIVATE KEY-----
  MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQD5QsuEGzXbuHnM
  A2ycUmXm32l5ohU7/9YhL79DQmhQgNrjTVR+3K7KfFCq5BqcUoY12jClBZTOwjof
  HjtjK1qDIXBDIpynuVToMA4KNAqFVgzOXoalLy8i8bnU9oNAWWkLBmJ98o8Fg4DV
  FvxiCfUciXookQCnvvj2TqoOUPWc6PtJ9ZAIS0yeAVcqQ6p5Ah6jMXmvHnsDF8uP
  S8YYaEQ5k+UEYgkdj/xY1eHEjCCOWkOyIB13aarwI3qwNlQc/cM9sqKEBqKuk9G0
  A4lbQR00k8xsDAxpD4HKBPZ52/HKp5+cjTY5WnPAvGw5w+HAELFbg0tT+cU3Jsm9
  jz+jO6s3AgMBAAECggEAbV+O18/syRXgc9HI1aseRbkgmhux/5raBcPixAuepDx2
  T6j9+5CwLe9wohvnRVK8y2KLV83kJvl48XCdlH1QgRuqG/tTDBG5nQyBDJ8bQrio
  c+FsaY0TvNyes0DcBN92xTyu+R72/O9gF6C3a/l8kWINtUEzLWgR7FpGKnQB4jBH
  a0mXv/GMY30CF+RPXfPyhZl9aNRiiImBvayHa2g0rP1Bs43MXP6D61UyKNXaXMy8
  BfGdMQ9AQ3GNZd8L+Lylzj2QIUy0io46BL7d7ZQm3VGIvdLFjHJ6WLHQhlpGCsF4
  c01WTLzZuqdzJ+vuysTfjpCTasjuOFQgzu7L4t2N6QKBgQD9arDGdWURfMPb6vnM
  0kjCG/oWKTgBBIhPK2XuQ/kouuUzqaRxfVl61pwwJ9cHqHExUMmC3bDGeUVTmEfj
  KdgUWPVixwLypmpiVzYvUfiHoZhTJfCYXFtj4GwEyAohuEVvLtpe+FKWnt4u7+9m
  AAbzZwzcP9WfNTWHbZkNVi7t+wKBgQD7zUJtkKT5nAY/Q+Vyact0kW+bH4t7740S
  KK2ZKLbbtYCr2H9LqlX1Q91UTJi5aFFPGthcYtPT2wchf8fA9KMjA7l2Vi2JxuJd
  IY8la6ANm2Hm1G5EWYwF9IcjRzxOWVaYwVPbrYCgajk0HagXPQA9kFRo8R3vSJiO
  dgfsHoOe9QKBgFW49m1bnsGom7RTqwZvB6+puRIwBULK3rUxL/zGP41Yk1nDg93k
  EhWsbQ8ZGvL7NrcA5fl/tmGc+ieJ9p9QM0jGwtMUENo2EvyLFcgyCUkQD6/owJc5
  fqytaLzBUjQP2mT+y12e0Ikk2nG0Nh4h2jgR3tbOPRvq6t2R5FkPkzZrAoGBAOTg
  NAtHOM2yJnOHEZ4nz8lLEPkdeTnUCpSA6RqYSW330tdg2IQ8dhmT8DBZ11BgI9gV
  fKitJAIjyp2GellHhKmlDwUjXA0p/EPO50CKTVdQ73JTkU8LXh1joRpN++Dzj6UV
  xVWepZYqN4jJlCpbRkavVCp3UFBZ2mFTo+vZ6KWpAoGBAIBqTZ0JDptSw0HKMCMy
  gPB1Pjr6XZ85DVUep6lB94fnWjTopE4oNLfQJ18tA5egX4ZGNBhJxXostQM+FAln
  X1fZ8SwDO9vG0MJUHro4iT26+1pPT4C+/d65x0wgjdlPlhKbiHTzqB4OBILBsDwz
  J7m1TfZ7oGUE5mYccINSEGgu
  -----END PRIVATE KEY-----
  EOT
}

resource "hcloud_network" "private_network" {
  name     = var.network_name
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "network_subnet" {
  for_each     = local.groups
  network_id   = hcloud_network.private_network.id
  type         = "cloud"
  network_zone = var.network_location
  ip_range     = "10.0.${each.value.subnet}.0/24"
}

resource "hcloud_placement_group" "placement_group" {
  count = local.placement_groups
  name  = "server_placement_spread_group-${count.index}"
  type  = "spread"
}


resource "hcloud_firewall" "network_firewall" {
  name = var.firewall_name
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "1-10000"
    # TODO: add support for home ip address
    # source_ips = var.allow_ips
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

resource "hcloud_server" "server_node" {
  for_each           = { for entry in local.servers : "${entry.name}" => entry }
  name               = each.value.name
  image              = local.instance_image
  server_type        = each.value.server_type
  location           = var.server_location
  placement_group_id = hcloud_placement_group.placement_group[each.value.group].id
  firewall_ids       = [hcloud_firewall.network_firewall.id]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
  depends_on = [
    hcloud_network_subnet.network_subnet["bootstrap"],
    hcloud_network_subnet.network_subnet["consul"],
    hcloud_network_subnet.network_subnet["nomad-server"],
    hcloud_network_subnet.network_subnet["vault"],
    hcloud_network_subnet.network_subnet["client"],
    hcloud_network_subnet.network_subnet["observability"],
  ]

  labels = {
    "group" = each.value.group_name
  }

  ssh_keys = [
    hcloud_ssh_key.admin.id
  ]
}

resource "hcloud_server_network" "network_binding" {
  for_each   = { for entry in local.servers : "${entry.name}" => entry }
  server_id  = hcloud_server.server_node[each.value.name].id
  network_id = hcloud_network.private_network.id
  ip         = each.value.private_ip
}

resource "hcloud_volume" "consul" {
  count    = var.server_count
  location = var.server_location
  name     = "consul-${count.index}"
  size     = var.consul_volume_size
  format   = "ext4"
  depends_on = [
    hcloud_server.server_node 
  ]
}

resource "hcloud_volume" "vault" {
  count    = var.vault_count
  location = var.server_location
  name     = "vault-${count.index}"
  size     = var.vault_volume_size
  format   = "ext4"
  depends_on = [
    hcloud_server.server_node 
  ]
}

resource "hcloud_volume" "client_volumes" {
  for_each = { for entry in var.client_volumes : "${entry.name}" => entry.size }
  location = var.server_location
  name     = "${each.key}"
  size     = each.value
  format   = "ext4"
  depends_on = [
    hcloud_server.server_node 
  ]
}

resource "hcloud_volume_attachment" "client_volumes" {
  for_each = { for index, entry in var.client_volumes : entry.name => entry.client_id }
  volume_id = hcloud_volume.client_volumes[each.key].id
  server_id = hcloud_server.server_node["${var.base_server_name}-client-${each.value}"].id
  automount = true

  depends_on = [
    hcloud_volume.client_volumes 
  ]
}

resource "hcloud_volume_attachment" "consul" {
  for_each = {for key, val in local.servers: val.index => val.name if val.group_name == local.consul_group}
  volume_id = hcloud_volume.consul[each.key].id
  server_id = hcloud_server.server_node[each.value].id
  automount = true

  depends_on = [
    hcloud_volume.consul 
  ]
}

resource "hcloud_volume_attachment" "vault" {
  for_each = {for key, val in local.servers: val.index => val.name if val.group_name == "vault"}
  volume_id = hcloud_volume.vault[each.key].id
  server_id = hcloud_server.server_node[each.value].id
  automount = true

  depends_on = [
    hcloud_volume.vault 
  ]
}

resource "hcloud_load_balancer" "lb1" {
  name               = "lb1"
  load_balancer_type = var.load_balancer_type
  # network_zone       =  hcloud_network_subnet.network_subnet["consul"].network_zone
  location           = var.load_balancer_location
  depends_on = [
    hcloud_server.server_node,
    hcloud_server_network.network_binding,
    hcloud_network_subnet.network_subnet["client"],
    hcloud_network_subnet.network_subnet["consul"],
  ]
}

resource "hcloud_load_balancer_network" "srvnetwork" {
  load_balancer_id = hcloud_load_balancer.lb1.id
  network_id       = hcloud_network.private_network.id
  ip               = "10.0.0.${var.server_count + 1}"
  depends_on = [
    hcloud_network.private_network
  ]
}

resource "hcloud_load_balancer_service" "load_balancer_service" {
    load_balancer_id = hcloud_load_balancer.lb1.id
    protocol         = "https"
    destination_port = 80
    http {
      certificates   = [hcloud_uploaded_certificate.certificate.id] 
    }
}

# this is unfortunately necessary, because no amount of `depends_on` on the load_balancer_target will ensure
# the nodes and networks are ready for load_balancer target attachment, other than waiting
resource "time_sleep" "wait" {
  create_duration = "30s"
  depends_on = [
    hcloud_server.server_node,
    hcloud_server_network.network_binding,
    hcloud_network_subnet.network_subnet["client"],
  ]
}

resource "hcloud_load_balancer_target" "load_balancer_target" {
  for_each         = {for key, val in local.servers: val.index => val.name if val.group_name == "client"}
  type             = "server"
  load_balancer_id = hcloud_load_balancer.lb1.id
  server_id        = hcloud_server.server_node[each.value].id
  use_private_ip   = true
  depends_on       = [time_sleep.wait]
}
