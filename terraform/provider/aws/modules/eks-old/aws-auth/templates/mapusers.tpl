%{ for user in devs ~}
    - userarn: arn:aws:iam::${caller_identity}:user/${user}
      username: ${user}
      groups:
        - system:user
%{ endfor ~}
%{ for user in admins ~}
    - userarn: arn:aws:iam::${caller_identity}:user/${user}
      username: ${user}
      groups:
        - system:masters
%{ endfor ~}