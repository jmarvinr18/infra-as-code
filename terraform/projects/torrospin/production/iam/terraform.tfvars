iam_user_name = "grafana-metrics-exporter"

policy_details = [
  {
    name = "CloudWatchReadOnlyAccess",
    file = "../../../policies/cloud-watch-read-only-access.json",
  },
  {
    name = "CloudWatchLogsReadOnlyAccess",
    file = "../../../policies/cloud-watch-logs-read-only-access.json",
  }
]