locals {
  list = distinct(compact(split("\n", file("${path.module}/ips.txt"))))

  ips = [
    for ip in local.list :
    format("%s/32", ip)
  ]
}