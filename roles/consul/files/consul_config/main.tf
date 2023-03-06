resource "consul_acl_policy" "clients_write" {
  name        = "clients_write"
  datacenters = [var.datacenter]
  rules       = <<-RULE
    node_prefix "" {
      policy = "write"
    }
    RULE
}

resource "consul_acl_policy" "prometheus" {
  name        = "prometheus"
  datacenters = [var.datacenter]
  rules       = <<-RULE
    node_prefix "" {
      policy = "read"
    }

    agent_prefix "" {
      policy = "read"
    }

    service_prefix "" {
      policy = "read"
    }
    RULE
}


resource "consul_acl_policy" "nomad_server" {
  name        = "nomad_server"
  datacenters = [var.datacenter]
  rules       = <<-RULE
    agent_prefix "" {
      policy = "read"
    }

    node_prefix "" {
      policy = "read"
    }

    service_prefix "" {
      policy = "write"
    }

    mesh = "write"

    acl = "write"
    RULE
}

resource "consul_acl_token" "nomad_server" {
  description = "nomad servers token"
  policies    = [consul_acl_policy.nomad_server.name]
  local       = true
}

resource "consul_acl_token" "prometheus" {
  description = "prometheus token"
  policies    = [consul_acl_policy.prometheus.name]
  local       = true
}


resource "consul_acl_policy" "nomad_client" {
  name        = "nomad_client"
  datacenters = [var.datacenter]
  rules       = <<-RULE
    agent_prefix "" {
      policy = "read"
    }

    node_prefix "" {
      policy = "read"
    }

    service_prefix "" {
      policy = "write"
    }

    key_prefix "" {
      policy = "read"
    }
    RULE
}

resource "consul_acl_policy" "client_auto_encrypt" {
  name        = "client_auto_encrypt"
  datacenters = [var.datacenter]
  rules       = <<-RULE
    node_prefix "" {
      policy = "write"
    }
    service_prefix "" {
      policy = "write"
    }
    RULE
}

resource "consul_acl_token" "client_auto_encrypt_token" {
  description = "client auto encrypt"
  policies    = [consul_acl_policy.client_auto_encrypt.name]
  local       = true
}


resource "consul_acl_token" "nomad_client" {
  description = "nomad clients token"
  policies    = [consul_acl_policy.nomad_client.name]
  local       = true
}


resource "consul_acl_policy" "promtail" {
  name        = "promtail_sd"
  datacenters = [var.datacenter]
  rules       = <<-RULE
    agent_prefix "" {
      policy = "read"
    }

    node_prefix "" {
      policy = "read"
    }

    service_prefix "" {
      policy = "read"
    }
    RULE
}

resource "consul_acl_token" "promtail" {
  description = "promtail token"
  policies    = [consul_acl_policy.promtail.name]
  local       = true
}

resource "consul_acl_policy" "telemetry" {
  name        = "telemetry"
  datacenters = [var.datacenter]
  rules       = <<-RULE
    agent_prefix "" {
      policy = "read"
    }
    RULE
}

resource "consul_acl_token" "telemetry" {
  description = "telemetry token"
  policies    = [consul_acl_policy.telemetry.name]
  local       = true
}
