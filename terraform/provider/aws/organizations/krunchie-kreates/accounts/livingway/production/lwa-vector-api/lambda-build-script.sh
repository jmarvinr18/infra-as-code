#!/bin/bash


rm -rf layer && mkdir -p layer/python
pip install \
  --platform manylinux2014_x86_64 \
  --implementation cp --python-version 3.12 \
  --only-binary=:all: --target layer/python \
  "psycopg[binary]"

find layer -name '__pycache__' -type d -exec rm -rf {} +
ls layer/python/psycopg_binary/ | grep -c '\.so'   # expect 2

cd layer && zip -r ../psycopg-layer.zip python && cd ..

aws lambda publish-layer-version \
  --layer-name psycopg --zip-file fileb://psycopg-layer.zip \
  --compatible-runtimes python3.12 --compatible-architectures x86_64 \
  --region ap-southeast-1