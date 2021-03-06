
locals {
  # Sort environment variables so terraform will not try to recreate on each plan/apply
  env_vars             = var.environment != null ? var.environment : []
  env_vars_keys        = [for m in local.env_vars : lookup(m, "name")]
  env_vars_values      = [for m in local.env_vars : lookup(m, "value")]
  env_vars_as_map      = zipmap(local.env_vars_keys, local.env_vars_values)
  sorted_env_vars_keys = sort(local.env_vars_keys)
  sorted_environment_vars = [
    for key in local.sorted_env_vars_keys :
    {
      name  = key
      value = lookup(local.env_vars_as_map, key)
    }
  ]
  # This strange-looking variable is needed because terraform (currently) does not support explicit `null` in ternary operator,
  # so this does not work: final_environment_vars = length(local.sorted_environment_vars) > 0 ? local.sorted_environment_vars : null
  env_null_value = var.environment == null ? var.environment : null
  # https://www.terraform.io/docs/configuration/expressions.html#null

  final_environment_vars = length(local.sorted_environment_vars) > 0 ? local.sorted_environment_vars : local.env_null_value
  # Sort secerts  so terraform will not try to recreate on each plan/apply
  secrets             = var.secrets != null ? var.secrets : []
  secrets_keys        = [for m in local.secrets : lookup(m, "name")]
  secrets_values      = [for m in local.secrets : lookup(m, "valueFrom")]
  secrets_as_map      = zipmap(local.secrets_keys, local.secrets_values)
  sorted_secrets_keys = sort(local.secrets_keys)
  sorted_secrets_vars = [
    for key in local.sorted_secrets_keys :
    {
      name      = key
      valueFrom = lookup(local.secrets_as_map, key)
    }
  ]
  # https://www.terraform.io/docs/configuration/expressions.html#null
  final_secrets = length(local.sorted_secrets_vars) > 0 ? local.sorted_secrets_vars : []

  container_definition = {
    name                   = var.container_name
    image                  = "${var.container_image_base}:${var.container_image_tag}"
    image                  = "${var.container_image_base}:${var.container_image_tag}"
    essential              = var.essential
    entryPoint             = var.entrypoint
    command                = var.command
    workingDirectory       = var.working_directory
    readonlyRootFilesystem = var.readonly_root_filesystem
    mountPoints            = var.mount_points
    dnsServers             = var.dns_servers
    ulimits                = var.ulimits
    repositoryCredentials  = var.repository_credentials
    links                  = var.links
    volumesFrom            = var.volumes_from
    user                   = var.user
    dependsOn              = var.container_depends_on
    privileged             = var.privileged
    portMappings           = var.port_mappings
    healthCheck            = var.healthcheck
    firelensConfiguration  = var.firelens_configuration
    linuxParameters        = var.linux_parameters
    logConfiguration       = var.log_configuration
    memory                 = var.container_memory
    memoryReservation      = var.container_memory_reservation
    networkMode            = var.container_network_mode
    cpu                    = var.container_cpu
    environment            = local.final_environment_vars
    environmentFiles       = var.environment_files
    secrets                = local.final_secrets
    dockerLabels           = var.docker_labels
    startTimeout           = var.start_timeout
    stopTimeout            = var.stop_timeout
    systemControls         = var.system_controls
  }

  json_map = jsonencode(local.container_definition)
}
