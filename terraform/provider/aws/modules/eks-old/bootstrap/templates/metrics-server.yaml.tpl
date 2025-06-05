---
defaultArgs:
  - --cert-dir=/tmp
  - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
  - --kubelet-use-node-status-port
  - --metric-resolution=15s
  - --secure-port=10250
# hostNetwork.enabled: "true"
# affinity:
#   nodeAffinity:
#     requiredDuringSchedulingIgnoredDuringExecution:
#       nodeSelectorTerms:
#         - matchExpressions:
#             - key: purpose
#               operator: In
#               values:
#                 - monitoring
#   podAntiAffinity:
#     requiredDuringSchedulingIgnoredDuringExecution:
#       - labelSelector:
#           matchExpressions:
#             - key: app.kubernetes.io/name
#               operator: In
#               values:
#                 - prometheus
#         topologyKey: "kubernetes.io/hostname"
