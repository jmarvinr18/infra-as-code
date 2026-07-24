# AWS VPC Setup Guide — Per-Client Onboarding (Agentic RAG Ready)

**Owner:** Krunchie Kreates Digital Agency — Platform / DevOps
**Audience:** Backend Engineer, DevOps, Project Manager
**Isolation model:** One dedicated AWS account **per client**, one VPC per account
**Applies to:** Every new client account onboarded
**Last updated:** 2026-07-24

---

## 1. Purpose & Scope

This is the standard, repeatable runbook for provisioning the network foundation of a new client. Every client gets:

- Their **own AWS account** (created under our AWS Organization) for hard billing + blast-radius isolation.
- **One VPC** per account, built to the same template, so every client environment looks identical.
- A network that is **agentic-RAG ready** on day one: private connectivity to Amazon Bedrock, Amazon S3, Amazon OpenSearch Serverless (vector store), Secrets Manager, and CloudWatch — with no data traversing the public internet.

You will build the same result two ways: through the **AWS Console (UI)** for understanding and one-off work, and with **Terraform** for the production, repeatable path. **Terraform is the source of truth.** The console walkthrough exists so the team understands what the code creates and can debug it.

> Rule of thumb: **click once to learn it, codify it forever.** After a client is live, changes go through Terraform + pull request, never the console.

---

## 2. Why account-per-client (design rationale)

| Concern | How account-per-client helps |
|---|---|
| Data isolation | A client's data, keys, and RAG index physically live in a separate account. Cross-client access is impossible by default. |
| Blast radius | A misconfiguration or compromised credential is contained to one account. |
| Billing & cost | Each client's spend is a clean, separate bill — trivial to invoice or show cost transparency. |
| Compliance | Easy to prove tenant isolation to a client's security/legal team. |
| Offboarding | Closing a client = closing/quarantining one account. No untangling shared resources. |

We manage all client accounts centrally with **AWS Organizations**, a shared **management account**, and (recommended) **AWS Control Tower** for guardrails. Terraform state and CI/CD live in a separate **shared-services/tooling account** — never inside a client account.

```
AWS Organization
├── Management account (billing, SCPs, org root)
├── Shared-Services account (Terraform state bucket, CI/CD, central logging)
├── Log-Archive account (centralized CloudTrail/config logs)
└── Workloads OU
    ├── client-acme-prod      → VPC 10.20.0.0/16
    ├── client-acme-staging   → VPC 10.21.0.0/16
    ├── client-globex-prod    → VPC 10.30.0.0/16
    └── ...                    (one account per client per environment)
```

---

## 3. Prerequisites (one-time, done by Platform team)

Before onboarding any client you need:

1. **AWS Organization** set up with the management account, and ideally **Control Tower** enabled.
2. A **Shared-Services account** containing:
   - An S3 bucket for Terraform state (versioned + encrypted), e.g. `kk-tfstate-<orgid>`.
   - A DynamoDB table for state locking, e.g. `kk-tf-locks`.
   - An OIDC-federated IAM role for CI/CD (GitHub Actions) — no long-lived keys.
3. Terraform **>= 1.6** and the **AWS provider >= 5.x** installed locally / in CI.
4. A decided **CIDR allocation plan** (Section 4) so no two clients overlap — critical if you ever peer VPCs or use Transit Gateway.
5. AWS CLI configured with SSO (`aws configure sso`) — **no static access keys.**

---

## 4. Naming, tagging & CIDR conventions

Consistency is what makes this repeatable. Apply these to **every** resource.

### 4.1 Naming convention

`kk-<client>-<env>-<resource>` — all lowercase, hyphenated.

Examples: `kk-acme-prod-vpc`, `kk-acme-prod-subnet-private-a`, `kk-acme-prod-natgw-a`.

### 4.2 Mandatory tags (enforced via SCP / tag policy)

| Tag | Example | Purpose |
|---|---|---|
| `Client` | `acme` | Which client owns this |
| `Environment` | `prod` / `staging` / `dev` | Lifecycle stage |
| `ManagedBy` | `terraform` | Never hand-edit tagged `terraform` |
| `CostCenter` | `acme` | Billing rollup |
| `Project` | `agentic-rag` | Workload |
| `Owner` | `platform@krunchie...` | Escalation contact |

### 4.3 CIDR allocation plan

Give each client a **/16**, and never reuse. Split each /16 into a predictable pattern so every VPC's subnets are at the same offsets.

Per-VPC layout (example for `10.20.0.0/16`), across **3 Availability Zones**:

| Tier | AZ-a | AZ-b | AZ-c | Notes |
|---|---|---|---|---|
| **Public** | 10.20.0.0/24 | 10.20.1.0/24 | 10.20.2.0/24 | NAT gateways, load balancers only |
| **Private (app)** | 10.20.16.0/20 | 10.20.32.0/20 | 10.20.48.0/20 | Agent runtime / ECS / Lambda / EKS |
| **Data (RAG)** | 10.20.64.0/22 | 10.20.68.0/22 | 10.20.72.0/22 | OpenSearch Serverless, RDS, ElastiCache |

Keep a central registry (a simple table in your repo or the state) mapping `client → /16`:

```
acme-prod   10.20.0.0/16
acme-stg    10.21.0.0/16
globex-prod 10.30.0.0/16
```

**Best practice:** never use the default VPC, and never use overlapping RFC1918 ranges across clients you might ever connect.

---

## 5. Target architecture (what you're building)

```
                       ┌─────────────────────────────────────────────┐
                       │  Client AWS Account: kk-acme-prod            │
                       │  VPC 10.20.0.0/16  (3 AZs)                   │
   Internet            │                                             │
      │   ┌────────────┤  PUBLIC subnets  ── IGW ── NAT GW (per AZ)  │
      └───┤ IGW        │      (egress only for private tiers)        │
          └────────────┤                                             │
                       │  PRIVATE (app) subnets                      │
                       │    • Agent runtime (ECS Fargate / Lambda)   │
                       │    • No public IPs                          │
                       │                                             │
                       │  DATA (RAG) subnets                         │
                       │    • OpenSearch Serverless (vector store)   │
                       │    • RDS / ElastiCache (metadata/cache)     │
                       │                                             │
                       │  VPC Endpoints (PrivateLink, no NAT needed):│
                       │    Interface: bedrock-runtime, bedrock,     │
                       │      secretsmanager, logs, ecr.api,         │
                       │      ecr.dkr, sts, aoss                     │
                       │    Gateway:   s3, dynamodb                  │
                       └─────────────────────────────────────────────┘
```

Key properties: private subnets reach AWS services (Bedrock, S3, OpenSearch) over **PrivateLink**, not the internet. NAT gateways exist only for outbound package/API calls the RAG stack genuinely needs; if you can avoid all public egress, you can drop NAT entirely and rely purely on endpoints.

---

## 6. Part A — Console UI walkthrough (step-by-step)

Do this while **logged into the client's account** (via AWS SSO / IAM Identity Center → select the client account → AdministratorAccess for setup only). Region example: `us-east-1`.

> This section builds one client VPC by hand so you understand the pieces. For real onboarding, use Part B (Terraform).

### Step 1 — Create the VPC (VPC + subnets in one shot)

1. Console → **VPC** → **Create VPC**.
2. Select **VPC and more** (this creates subnets, route tables, and gateways together).
3. **Name tag auto-generation:** `kk-acme-prod`.
4. **IPv4 CIDR:** `10.20.0.0/16`. Leave IPv6 off unless required.
5. **Tenancy:** Default.
6. **Number of Availability Zones:** `3`.
7. **Public subnets:** `3`. **Private subnets:** `3` (you'll add the data tier separately, or bump to 6 and relabel).
8. **NAT gateways:** **1 per AZ** for production (high availability). For dev, "In 1 AZ" saves cost.
9. **VPC endpoints:** select **S3 Gateway** (free — always include it).
10. **DNS options:** enable **both** "Enable DNS hostnames" and "Enable DNS resolution" (required for interface endpoints and OpenSearch).
11. Click **Create VPC** and wait for the workflow to finish.

### Step 2 — Add the data (RAG) subnets

The wizard made public + private. Add a dedicated data tier:

1. **VPC → Subnets → Create subnet.**
2. VPC: `kk-acme-prod`.
3. Create three subnets, one per AZ, using the data CIDRs from Section 4.3 (`10.20.64.0/22`, `10.20.68.0/22`, `10.20.72.0/22`).
4. Name them `kk-acme-prod-subnet-data-a/b/c`.
5. Associate them with the **private route tables** (no direct internet route).

### Step 3 — Verify Internet Gateway & NAT

1. **VPC → Internet gateways** — confirm one is attached to the VPC.
2. **VPC → NAT gateways** — confirm one per AZ, each in a **public** subnet with an Elastic IP.
3. **VPC → Route tables:**
   - Public RT: `0.0.0.0/0 → igw-...`
   - Each private/data RT: `0.0.0.0/0 → nat-...` (matching AZ).

### Step 4 — Create Interface VPC Endpoints (PrivateLink) for RAG

These keep Bedrock/OpenSearch/Secrets traffic inside AWS. **VPC → Endpoints → Create endpoint**, repeat for each service below:

| Service name | Why (RAG use) |
|---|---|
| `com.amazonaws.us-east-1.bedrock-runtime` | Model inference (embeddings + generation) |
| `com.amazonaws.us-east-1.bedrock` | Model management / agent config |
| `com.amazonaws.us-east-1.aoss` | OpenSearch Serverless (vector store) data plane |
| `com.amazonaws.us-east-1.secretsmanager` | API keys / DB creds |
| `com.amazonaws.us-east-1.logs` | CloudWatch Logs |
| `com.amazonaws.us-east-1.ecr.api` + `ecr.dkr` | Pull agent container images |
| `com.amazonaws.us-east-1.sts` | Role assumption for the agent |

For each:
1. Type: **AWS services**, search the service name.
2. VPC: `kk-acme-prod`.
3. Subnets: select the **private (app) subnets** in all 3 AZs.
4. **Enable DNS name** (Private DNS) — so SDK calls resolve to the endpoint automatically.
5. Security group: the **endpoints SG** (Step 5).
6. Policy: start with "Full access," then tighten to least-privilege later.

Also add **Gateway endpoints** for `s3` and `dynamodb` (free) via the same menu — attach to all private/data route tables.

### Step 5 — Security groups (least privilege)

Create these, all named `kk-acme-prod-sg-*`:

1. **`sg-endpoints`** — for the interface endpoints. Inbound: **HTTPS 443** from the VPC CIDR (`10.20.0.0/16`) only. Outbound: none needed.
2. **`sg-agent`** — for the agent runtime (ECS/Lambda). Inbound: from ALB SG only (or none for Lambda). Outbound: **443 to `sg-endpoints`** and to `sg-data`.
3. **`sg-data`** — for OpenSearch/RDS. Inbound: from `sg-agent` only, on the service port (e.g. 443 for AOSS, 5432 for Postgres). Outbound: none.

**Never** use `0.0.0.0/0` inbound on anything except a public ALB on 443.

### Step 6 — Enable VPC Flow Logs

1. **VPC → your VPC → Flow logs → Create flow log.**
2. Filter: **All.**
3. Destination: **CloudWatch Logs** (or S3 in the log-archive account).
4. This is mandatory for security review and debugging.

### Step 7 — Sanity check

- Launch a test ECS task / Lambda in a private subnet; confirm it can call `bedrock-runtime` and reach `s3` **without** a public IP.
- Confirm nothing in private/data subnets has `Auto-assign public IP = Yes`.

Once this works, **throw the hand-built VPC away and recreate it with Terraform** (Part B) so it's reproducible.

---

## 7. Part B — Terraform (the real onboarding path)

Structure the repo so a **reusable module** defines the network, and each **client/env** is a thin instantiation. Onboarding a new client = copy one small folder, change ~5 variables, `terraform apply`.

### 7.1 Repository layout

```
infra/
├── modules/
│   └── client-vpc/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── endpoints.tf
└── live/
    ├── acme/
    │   ├── prod/
    │   │   ├── backend.tf
    │   │   ├── providers.tf
    │   │   └── main.tf
    │   └── staging/
    └── globex/
        └── prod/
```

### 7.2 Remote state & locking (`live/acme/prod/backend.tf`)

State lives in the **shared-services** account, one key per client/env. Never store state in the client account.

```hcl
terraform {
  required_version = ">= 1.6"
  backend "s3" {
    bucket         = "kk-tfstate-<orgid>"
    key            = "clients/acme/prod/vpc.tfstate"
    region         = "us-east-1"
    dynamodb_table = "kk-tf-locks"
    encrypt        = true
  }
}
```

### 7.3 Provider with role assumption (`live/acme/prod/providers.tf`)

CI assumes a role **into the client account** — no static keys.

```hcl
terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.40" }
  }
}

provider "aws" {
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::${var.client_account_id}:role/OrganizationAccountAccessRole"
  }
  default_tags {
    tags = {
      Client      = var.client
      Environment = var.environment
      ManagedBy   = "terraform"
      Project     = "agentic-rag"
    }
  }
}
```

### 7.4 The reusable module — `modules/client-vpc/variables.tf`

```hcl
variable "client"       { type = string }
variable "environment"  { type = string }
variable "region"       { type = string  default = "us-east-1" }
variable "vpc_cidr"     { type = string }             # e.g. "10.20.0.0/16"
variable "az_count"     { type = number  default = 3 }
variable "single_nat"   { type = bool    default = false } # true for dev to save cost

# Interface endpoints to create for the RAG stack
variable "interface_endpoints" {
  type    = list(string)
  default = [
    "bedrock-runtime", "bedrock", "aoss",
    "secretsmanager", "logs", "sts",
    "ecr.api", "ecr.dkr",
  ]
}
```

### 7.5 `modules/client-vpc/main.tf`

We lean on the community-maintained `terraform-aws-modules/vpc/aws` module for the base network (battle-tested, follows AWS best practice), then layer our conventions on top.

```hcl
locals {
  name = "kk-${var.client}-${var.environment}"
  azs  = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # Deterministic subnet carving from the /16
  public_subnets  = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i)]          # /24s
  private_subnets = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 4, i + 1)]      # /20s
  data_subnets    = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 6, i + 16)]     # /22s
}

data "aws_availability_zones" "available" { state = "available" }

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8"

  name = "${local.name}-vpc"
  cidr = var.vpc_cidr
  azs  = local.azs

  public_subnets   = local.public_subnets
  private_subnets  = local.private_subnets
  database_subnets = local.data_subnets

  # NAT: one per AZ in prod, single in dev
  enable_nat_gateway     = true
  single_nat_gateway     = var.single_nat
  one_nat_gateway_per_az = !var.single_nat

  enable_dns_hostnames = true
  enable_dns_support   = true

  # Flow logs -> CloudWatch, mandatory
  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  public_subnet_tags   = { Tier = "public" }
  private_subnet_tags  = { Tier = "app" }
  database_subnet_tags = { Tier = "data" }

  tags = { Name = "${local.name}-vpc" }
}
```

### 7.6 `modules/client-vpc/endpoints.tf` — PrivateLink for RAG

```hcl
# Security group for interface endpoints: 443 from the VPC only
resource "aws_security_group" "endpoints" {
  name_prefix = "${local.name}-sg-endpoints-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  tags = { Name = "${local.name}-sg-endpoints" }
}

# Gateway endpoints (free): S3 + DynamoDB
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = concat(module.vpc.private_route_table_ids,
                             module.vpc.database_route_table_ids)
  tags = { Name = "${local.name}-vpce-s3" }
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = concat(module.vpc.private_route_table_ids,
                             module.vpc.database_route_table_ids)
  tags = { Name = "${local.name}-vpce-dynamodb" }
}

# Interface endpoints (PrivateLink) for Bedrock, OpenSearch Serverless, etc.
resource "aws_vpc_endpoint" "interface" {
  for_each = toset(var.interface_endpoints)

  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = { Name = "${local.name}-vpce-${each.value}" }
}
```

### 7.7 `modules/client-vpc/outputs.tf`

```hcl
output "vpc_id"            { value = module.vpc.vpc_id }
output "private_subnets"   { value = module.vpc.private_subnets }
output "data_subnets"      { value = module.vpc.database_subnets }
output "endpoints_sg_id"   { value = aws_security_group.endpoints.id }
output "vpc_cidr"          { value = var.vpc_cidr }
```

### 7.8 Instantiate one client — `live/acme/prod/main.tf`

This is the **entire per-client onboarding diff**:

```hcl
variable "client_account_id" { type = string }

module "network" {
  source = "../../../modules/client-vpc"

  client            = "acme"
  environment       = "prod"
  region            = "us-east-1"
  vpc_cidr          = "10.20.0.0/16"   # from the CIDR registry, Section 4.3
  single_nat        = false            # prod = HA
}
```

### 7.9 Apply

```bash
cd infra/live/acme/prod
terraform init
terraform plan  -var="client_account_id=111122223333" -out=tfplan
terraform apply tfplan
```

Review the plan carefully the first time. After that, everything is code-reviewed via pull request and applied by CI.

---

## 8. Agentic RAG readiness layer

The VPC above is the foundation. Here's what makes it *specifically* ready for an agentic RAG workload, and where each piece lands.

### 8.1 Component-to-subnet mapping

| RAG component | Where it runs | Notes |
|---|---|---|
| **Embedding + generation** (Amazon Bedrock) | Called from private subnets via `bedrock-runtime` endpoint | No model hosting to manage; traffic stays on PrivateLink |
| **Vector store** (OpenSearch Serverless, `aoss`) | Data subnets, reached via `aoss` interface endpoint | Set the collection's network policy to **VPC-only** |
| **Agent runtime / orchestrator** (ECS Fargate or Lambda) | Private (app) subnets | Holds the agent loop, tool-calling, retrieval logic |
| **Document/source store** (S3) | Reached via S3 **gateway** endpoint | Raw docs + processed chunks; bucket is private, SSE-KMS |
| **Metadata / cache** (RDS or ElastiCache) | Data subnets | Optional: conversation state, chunk metadata |
| **Secrets** (Secrets Manager) | via endpoint | Client API keys, DB creds — never in env vars/code |
| **Observability** (CloudWatch, X-Ray) | via `logs` endpoint | Trace agent steps and retrievals |

### 8.2 OpenSearch Serverless — lock the vector store to the VPC

When you provision the AOSS collection (separate Terraform, layered on this network), attach a **VPC network policy** so it is unreachable from the public internet:

```hcl
resource "aws_opensearchserverless_vpc_endpoint" "aoss" {
  name       = "kk-acme-prod-aoss"
  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.data_subnets
  security_group_ids = [aws_security_group.aoss.id]
}

resource "aws_opensearchserverless_security_policy" "network" {
  name = "kk-acme-prod-net"
  type = "network"
  policy = jsonencode([{
    Rules = [
      { ResourceType = "collection", Resource = ["collection/kk-acme-prod-rag"] },
      { ResourceType = "dashboard",  Resource = ["collection/kk-acme-prod-rag"] }
    ]
    AllowFromPublic = false
    SourceVPCEs     = [aws_opensearchserverless_vpc_endpoint.aoss.id]
  }])
}
```

### 8.3 Guardrails specific to RAG / agents

- **Bedrock Guardrails**: attach content filters + PII redaction to the model calls (config, not network — but decide it at onboarding).
- **Egress control**: agents that browse or call external tools must egress through the NAT + (ideally) a filtering proxy. If the agent needs *no* internet, remove NAT entirely and rely only on endpoints — smallest attack surface.
- **KMS per client**: one customer-managed KMS key per client account for S3, OpenSearch, and Secrets. Isolation + client-provable encryption.
- **IAM least privilege**: the agent's task role gets `bedrock:InvokeModel` on only the approved model IDs, `aoss:APIAccessAll` scoped to the one collection, and `s3:GetObject` on only the client's bucket prefix.
- **Endpoint policies**: tighten each interface endpoint's policy so, e.g., the `bedrock-runtime` endpoint only allows the approved model ARNs.

### 8.4 Cost note

NAT gateways and interface endpoints both bill hourly + per-GB. For **dev/staging**, set `single_nat = true` and trim `interface_endpoints` to just what you're actively testing. For **prod**, keep one NAT per AZ and the full endpoint set — resilience and privacy outweigh the cost.

---

## 9. Per-client onboarding checklist

Copy this into the client's ticket and check off every item.

**Account & access**

- [ ] New AWS account created under **Workloads OU** (via Control Tower / Organizations)
- [ ] Client added to CIDR registry with a unique **/16** (Section 4.3)
- [ ] SSO permission sets assigned; no static IAM keys anywhere
- [ ] Customer-managed **KMS key** created for the client

**Network (Terraform)**

- [ ] New folder `infra/live/<client>/<env>/` created from template
- [ ] `backend.tf` key set to `clients/<client>/<env>/vpc.tfstate`
- [ ] `vpc_cidr`, `client`, `environment`, `client_account_id` set
- [ ] `terraform plan` reviewed in a PR by a second engineer
- [ ] `terraform apply` run by CI; state confirmed in shared-services bucket

**RAG readiness**

- [ ] Interface endpoints present: `bedrock-runtime`, `bedrock`, `aoss`, `secretsmanager`, `logs`, `sts`, `ecr.api`, `ecr.dkr`
- [ ] Gateway endpoints present: `s3`, `dynamodb`
- [ ] OpenSearch Serverless collection set to **VPC-only** (AllowFromPublic = false)
- [ ] Agent task role scoped to approved model IDs + single AOSS collection + client S3 prefix
- [ ] Bedrock Guardrails attached

**Security baseline**

- [ ] VPC Flow Logs enabled and shipping to log-archive
- [ ] No resource has `0.0.0.0/0` inbound except the public ALB on 443
- [ ] No auto-assign public IP on private/data subnets
- [ ] All resources carry mandatory tags (Section 4.2)

### 9.1 Verification commands

Run these (with the client account assumed) after apply:

```bash
# VPC exists and DNS is on
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=kk-acme-prod-vpc" \
  --query 'Vpcs[].{Id:VpcId,Cidr:CidrBlock,DnsHost:EnableDnsHostnames}'

# All expected endpoints are 'available'
aws ec2 describe-vpc-endpoints \
  --filters "Name=vpc-id,Values=<vpc-id>" \
  --query 'VpcEndpoints[].{Svc:ServiceName,State:State}' --output table

# No public IPs auto-assigned on private subnets
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<vpc-id>" \
  --query 'Subnets[?MapPublicIpOnLaunch==`true`].SubnetId'

# Flow logs active
aws ec2 describe-flow-logs --filter "Name=resource-id,Values=<vpc-id>" \
  --query 'FlowLogs[].FlowLogStatus'
```

**Live connectivity test:** deploy a throwaway Lambda/ECS task into a private subnet and confirm it can call Bedrock and read S3 with no public route:

```bash
aws bedrock-runtime invoke-model --model-id <embedding-model-id> \
  --body '{"inputText":"connectivity test"}' /tmp/out.json && echo "Bedrock reachable via PrivateLink"
```

---

## 10. Offboarding / teardown

When a client leaves, isolation makes this clean:

1. Snapshot / export any data the client is entitled to (S3, OpenSearch index).
2. `terraform destroy` in `infra/live/<client>/<env>/`.
3. Revoke SSO permission sets.
4. **Suspend then close** the AWS account via Organizations (or move to a `Suspended` OU with a deny-all SCP for a retention period).
5. Free the client's **/16** in the CIDR registry only after account closure.
6. Delete or schedule deletion of the client KMS key.

---

## 11. Best-practice summary (the non-negotiables)

- **One account per client.** Isolation, billing, compliance, clean offboarding.
- **Terraform is the source of truth.** Console is for learning/debugging only.
- **Never the default VPC.** Deterministic, non-overlapping CIDRs from a registry.
- **Private by default.** Workloads in private subnets; PrivateLink to AWS services; internet only via NAT when unavoidable.
- **RAG traffic never touches the public internet** — Bedrock + OpenSearch over endpoints, vector store locked VPC-only.
- **Least privilege everywhere** — security groups, IAM roles, endpoint policies.
- **Per-client KMS + Flow Logs + mandatory tags** on everything.
- **Multi-AZ (3 AZs, NAT per AZ) in prod;** cost-trimmed single-NAT in dev.

---

*This runbook is versioned in the agency repo. Improve it via pull request as AWS services and our RAG stack evolve.*
