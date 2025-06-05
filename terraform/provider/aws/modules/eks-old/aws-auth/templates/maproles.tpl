%{ for role in roles ~}
- rolearn: arn:aws:iam::${caller_identity}:role/${role}
  username: ${role}
  groups:
    - system:masters
%{ endfor ~}