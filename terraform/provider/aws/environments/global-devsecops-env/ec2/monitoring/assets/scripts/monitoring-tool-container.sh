#!/bin/bash


# START PROMETHEUS SETUP =========================================================

mkdir prometheus
mkdir prometheus-data

sudo mv prometheus.yml prometheus

sudo chmod 777 prometheus prometheus-data

# Create persistent volume for your data
docker volume create prometheus-data
docker network create -d bridge prometheus-network

# Start Prometheus container
docker run \
    -d -p 9090:9090 \
    -v ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
    -v ./prometheus-data:/prometheus \
    --network=prometheus-network \
    prom/prometheus

# END PROMETHEUS SETUP =========================================================


# START BLACKBOX SETUP =========================================================

mkdir blackbox
sudo mv blackbox.yml blackbox
sudo chmod 777 blackbox

docker run --rm \
  -d -p 9115:9115 \
  --name blackbox_exporter \
  -v ./blackbox:/config \
  --network ip6net \
  quay.io/prometheus/blackbox-exporter:latest --config.file=./config/blackbox.yml

# END BLACKBOX SETUP =========================================================


# START GRAFANA SETUP =========================================================

# create a directory for your data
mkdir grafana-data

# start grafana with your user id and using the data directory
docker run -d -p 3000:3000 --name=grafana \
  --user "$(id -u)" \
  --volume "$PWD/grafana-data:/var/lib/grafana" \
  grafana/grafana-enterprise

# END GRAFANA SETUP =========================================================