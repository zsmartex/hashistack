
data "consul_acl_token_secret_id" "nomad_server" {
  accessor_id = consul_acl_token.nomad_server.accessor_id
}

data "consul_acl_token_secret_id" "nomad_client" {
  accessor_id = consul_acl_token.nomad_client.accessor_id
}

data "consul_acl_token_secret_id" "promtail" {
  accessor_id = consul_acl_token.promtail.accessor_id
}

data "consul_acl_token_secret_id" "client_auto_encrypt" {
  accessor_id = consul_acl_token.client_auto_encrypt_token.accessor_id
}

data "consul_acl_token_secret_id" "prometheus" {
  accessor_id = consul_acl_token.prometheus.accessor_id
}

data "consul_acl_token_secret_id" "telemetry" {
  accessor_id = consul_acl_token.telemetry.accessor_id
}

output "consul_acl_client_token" {
  value     = data.consul_acl_token_secret_id.client_auto_encrypt.secret_id
  sensitive = true
}


output "consul_acl_nomad_server_token" {
  value     = data.consul_acl_token_secret_id.nomad_server.secret_id
  sensitive = true
}

output "consul_acl_nomad_client_token" {
  value     = data.consul_acl_token_secret_id.nomad_client.secret_id
  sensitive = true
}

output "consul_acl_promtail_token" {
  value     = data.consul_acl_token_secret_id.promtail.secret_id
  sensitive = true
}

output "consul_acl_prometheus_token" {
  value     = data.consul_acl_token_secret_id.prometheus.secret_id
  sensitive = true
}

output "consul_acl_telemetry_token" {
  value     = data.consul_acl_token_secret_id.telemetry.secret_id
  sensitive = true
}

output "consul_nomad2vault_token" {
  value     = data.consul_acl_token_secret_id.client2vault.secret_id
  sensitive = true
}

output "consul_acl_vault_token" {
  value     = data.consul_acl_token_secret_id.vault.secret_id
  sensitive = true
}
