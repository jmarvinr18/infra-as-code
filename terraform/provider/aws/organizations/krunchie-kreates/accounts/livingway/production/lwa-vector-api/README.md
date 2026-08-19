# lwa-vector-api

API Gateway HTTP API → Lambda → RDS Postgres with pgvector.

```
client ──▶ HTTP API (routes + stage) ──▶ Lambda (in VPC) ──▶ RDS Postgres 16 + pgvector
```

## Modules used

| Module | Path |
| --- | --- |
| HTTP API, integrations, routes, stage | `modules/api_gateway/http_api` |
| Lambda function | `modules/lambda/function` |
| Lambda execution role | `modules/lambda/role` |
| Postgres instance, subnet group, parameter group, SG | `modules/rds/postgres` |
| Lambda security group | `modules/sg` |

The first and last of these are new; the rest already existed in the repo.

## Routes

| Route | Auth | Purpose |
| --- | --- | --- |
| `GET /health` | none | Liveness; also reports whether pgvector is enabled |
| `POST /documents` | none | Insert `{"content": str, "embedding": [float, ...]}` |
| `POST /search` | none | Nearest neighbours for `{"embedding": [...], "top_k": int}` |
| `POST /admin/init` | `AWS_IAM` | Create the `vector` extension, demo table and HNSW index |

Only `/admin/init` is locked down. Add an authorizer to the others before this
carries real traffic.

## Deploying

```bash
cp terraform.example.tfvars terraform.tfvars   # fill in client_account_id
terraform init
terraform plan  -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Then enable pgvector once, either by calling `POST /admin/init` with SigV4, or
by applying `sql/bootstrap.sql` directly:

```bash
psql "postgresql://postgres:$(terraform output -raw db_password)@$(terraform output -raw db_endpoint)/vectordb" \
  -f sql/bootstrap.sql
```

## The Postgres driver

The Python runtime has no Postgres driver, so every database-backed route
returns **501** until a `psycopg` layer is attached. Build one on Amazon Linux
(the binary wheel is platform-specific):

```bash
mkdir -p layer/python
pip install "psycopg[binary]" -t layer/python \
  --platform manylinux2014_aarch64 --only-binary=:all:
(cd layer && zip -r ../psycopg-layer.zip python)

aws lambda publish-layer-version \
  --layer-name psycopg \
  --zip-file fileb://psycopg-layer.zip \
  --compatible-runtimes python3.12
```

Put the resulting ARN in `layers` and re-apply. `GET /health` works without it
and will tell you the driver is missing.

## Password handling

`use_managed_master_password` picks between two trade-offs:

- **`false` (default).** Terraform generates the password and injects it into
  the function's environment. Nothing extra to pay for, but the password is in
  Terraform state — fine for a demo, not for anything holding real data.
- **`true`.** RDS generates and rotates the password in Secrets Manager. The
  function's ENIs have no route to the internet, so reading the secret needs an
  interface endpoint, which this stack creates for you at roughly **$7/month per
  AZ**. That is the single largest line item if you turn it on.

## Connecting a SQL client

Set `db_publicly_accessible = true` and list your own address in
`db_allowed_cidr_blocks` — the instance gets a public IP, but the security group
still only answers the CIDRs you name. `0.0.0.0/0` is rejected by a variable
validation.

```bash
curl -s https://checkip.amazonaws.com   # your address, add /32
```

TablePlus connection details:

| Field | Value |
| --- | --- |
| Host | `terraform output -raw db_endpoint` (drop the `:5432` suffix) |
| Port | `5432` |
| User | `terraform output -raw db_master_username` |
| Password | `terraform output -raw db_password` |
| Database | `vectordb` |
| SSL mode | **require** — Postgres 15+ sets `rds.force_ssl = 1`, so plaintext is refused |

Your ISP address usually changes over time; when the connection starts timing
out, re-run the `checkip` command and re-apply.

## Storage encryption and the KMS key

By default this stack creates its own KMS key for the database rather than
letting RDS fall back to the AWS-managed `aws/rds` key. That key is created
lazily on first use and is frequently absent in a fresh member account, so
`CreateDBInstance` fails with:

```
KMSKeyNotAccessibleFault: The specified KMS key [alias/aws/rds] does not exist,
is not enabled or you do not have permissions to access it.
```

Owning the key costs ~$1/month and makes the apply deterministic. The
alternatives:

- `db_create_kms_key = false` — go back to the AWS-managed key. Free, but only
  works once `aws/rds` exists in the account and region.
- `db_kms_key_id = "arn:..."` — use a key you already have.
- `db_storage_encrypted = false` — no encryption at rest, no key, no cost.
  Acceptable for a throwaway demo, not for real data.

## Cost

Defaults are chosen for a demo, in `ap-southeast-1`, roughly:

| | |
| --- | --- |
| `db.t4g.micro`, single-AZ | ~$12–15/mo (free tier covers 750 h for 12 months) |
| Customer-managed KMS key | $1/mo (see below; set `db_storage_encrypted = false` to avoid) |
| 20 GiB gp3 | ~$2.50/mo |
| 1 day of backups | negligible at this size |
| HTTP API | $1.00 per million requests |
| Lambda | free tier covers a demo |
| CloudWatch access logs, 14-day retention | cents |

Off by default because they are not free: Multi-AZ, Performance Insights,
Enhanced Monitoring, per-route detailed metrics, log exports to CloudWatch, and
the Secrets Manager endpoint above.

To stop paying between demos, `terraform destroy` — `skip_final_snapshot` and
`deletion_protection = false` are set so it tears down cleanly.
