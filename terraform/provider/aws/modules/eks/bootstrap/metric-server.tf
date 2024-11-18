resource "helm_release" "metrics_server" {
    name = local.metrics-server.chart_name
    repository = local.metrics-server.chart_repo
    chart = local.metrics-server.chart_name
    namespace = local.metrics-server.namespace
    version = local.metrics-server.chart_version
    values = [file("${path.module}/templates/${local.metrics-server.chart_name}.yaml")]
}