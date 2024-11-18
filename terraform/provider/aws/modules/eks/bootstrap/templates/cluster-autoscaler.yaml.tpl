---
fullnameOverride: ${sa_name}
awsRegion: ${region}
rbac:
  create: true
  serviceAccount:
    name: ${sa_name}
    annotations:
      eks.amazonaws.com/role-arn: ${role}
autoDiscovery:
  clusterName: ${cluster_name}
  enabled: true
  tags:
    - k8s.io/${sa_name}/enabled
    - k8s.io/${sa_name}/${cluster_name}
serviceMonitor:
  enabled: true
  interval: "30s"
  namespace: ${service_monitor_namespace}
extraArgs:
  v: 4
  stderrthreshold: info
  logtostderr: true
  expander: least-waste
  scale-down-enabled: true
  balance-similar-node-groups: true
  skip-nodes-with-local-storage: false
  skip-nodes-with-system-pods: false
image:
  repository: k8s.gcr.io/autoscaling/${sa_name}
  tag: ${image_tag}
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: node.kubernetes.io/lifecycle
              operator: In
              values:
                - spot
                - on-demand
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
            - key: node.kubernetes.io/lifecycle
              operator: In
              values:
                - spot
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
            - key: app.kubernetes.io/name
              operator: In
              values:
                - prometheus
        topologyKey: "kubernetes.io/hostname"
