
region = "ap-southeast-1"

tags = {
  "project"     = "aip-c01"
}

domain = "xctuality"
repository = "npm-store"
repository_name = "pkgs"

description = "Upstream proxy repos: key = repo name, value = external connection name"

external_connection_name = "public:npmjs"

upstreams = ["pypi-store", "npm-store"]

upstream_repos = {
    pypi-store = "public:pypi"
    npm-store  = "public:npmjs"
  }
