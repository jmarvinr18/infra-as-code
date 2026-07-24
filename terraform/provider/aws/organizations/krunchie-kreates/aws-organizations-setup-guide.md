# AWS Organizations Setup Guide — Client-per-Account Segregation

**Prepared for:** Krunchie Kreates Digital Agency
**Goal:** Stand up an AWS Organization where every client gets an isolated AWS account, governed by a shared set of guardrails and billed centrally.
**Last updated:** July 2026

---

## 1. Why this design

Giving each client their own AWS account is the strongest isolation boundary AWS offers. It gives you:

- **Hard blast-radius separation** — a mistake, breach, or runaway cost in one client account can't touch another.
- **Clean billing** — consolidated billing rolls every client into one invoice while still letting you see cost per client account.
- **Easy offboarding** — when an engagement ends you can close or hand over a single account instead of untangling shared resources.
- **Per-client guardrails** — Service Control Policies (SCPs) let you enforce rules (allowed regions, no root usage, required tags) across all client accounts at once.

The account that creates the organization is the **management account**. Treat it as sacred: no client workloads ever run in it. It exists only to manage the org, billing, and identity.

---

## 2. Recommended structure

```
Root
├── Management account            (billing + org admin only, no workloads)
├── OU: Security
│   ├── Log Archive account       (centralized CloudTrail / config logs)
│   └── Audit account             (read-only security tooling)
├── OU: Infrastructure
│   └── Shared Services account   (CI/CD, shared tooling, DNS)
├── OU: Clients
│   ├── OU: client-acme
│   │   ├── acme-prod
│   │   └── acme-staging
│   └── OU: client-globex
│       ├── globex-prod
│       └── globex-staging
└── OU: Sandbox
    └── Dev/experiment accounts
```

You don't need every branch on day one. The minimum viable version is **Root → Clients OU → one account per client**. Add the Security and Infrastructure OUs as you grow. Nesting a per-client OU (e.g. `client-acme`) lets you attach client-specific SCPs and, later, split prod/staging into separate accounts cleanly.

---

## 3. Prerequisites

- A single AWS account that will become the **management account**, with a verified payment method and a **root user secured by MFA**.
- Admin access to that account (either root, or an IAM user/role with `AdministratorAccess`).
- A **unique email address per member account** — AWS requires a distinct email for every account. Use a plus-addressing or catch-all scheme you control, e.g. `aws+acme-prod@krunchie.com`, `aws+globex-prod@krunchie.com`. You cannot reuse an email that already belongs to another AWS account.
- For the Terraform path: Terraform ≥ 1.5, the AWS CLI configured with management-account admin credentials, and an S3 bucket + DynamoDB table (or S3 native locking) for remote state.

---

# Part A — Doing it via the Console UI

### Step 1 — Create the organization

1. Sign in to the **management account** as an admin.
2. Open the **AWS Organizations** console: https://console.aws.amazon.com/organizations/
3. Choose **Create an organization**.
4. When prompted, choose **Enable all features** (not just consolidated billing). All features is required for SCPs and is the default for new organizations. If you ever created an org in "consolidated billing only" mode, go to **Settings → Enable all features** and complete the confirmation email sent to member accounts.

Your management account is now the org root.

### Step 2 — Create the OU structure

1. In the Organizations console, open the **AWS accounts** page. You'll see the **Root** with your management account inside it.
2. Select the **Root** checkbox, then **Actions → Organizational unit → Create new**.
3. Name it `Clients`. Repeat to create `Security`, `Infrastructure`, and `Sandbox` as needed.
4. (Optional, recommended) Select the `Clients` OU and create a nested OU per client, e.g. `client-acme`.

### Step 3 — Create a member account per client

1. On the **AWS accounts** page, choose **Add an AWS account → Create an AWS account**.
2. Fill in:
   - **AWS account name** — e.g. `acme-prod`
   - **Email address of the account's owner** — your unique per-account email, e.g. `aws+acme-prod@krunchie.com`
   - **IAM role name** — leave the default `OrganizationAccountAccessRole`. Organizations creates this role automatically in the new account; it lets the management account assume full admin into the member account.
3. Choose **Create AWS account**. Provisioning takes a minute or two.
4. Once created, select the new account and use **Actions → Move** to place it under the correct OU (e.g. `Clients / client-acme`).

Repeat for each client account (prod, staging, etc.).

### Step 4 — Access a member account

To operate inside a freshly created client account:

1. From the management account, switch role using: account ID of the member account + role `OrganizationAccountAccessRole`. In the console use the account menu → **Switch role**, or build the URL:
   `https://signin.aws.amazon.com/switchrole?account=<MEMBER_ACCOUNT_ID>&roleName=OrganizationAccountAccessRole&displayName=acme-prod`
2. For day-to-day human access, prefer **IAM Identity Center** (Step 6) over switch-role.

### Step 5 — Turn on Service Control Policies (guardrails)

1. In the Organizations console, open **Policies**.
2. Choose **Service control policies** and click **Enable service control policies** if not already on.
3. Create a baseline SCP that applies to all client accounts. Example — restrict to your operating regions and block root user actions:

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Sid": "DenyOutsideAllowedRegions",
         "Effect": "Deny",
         "NotAction": [
           "iam:*", "sts:*", "organizations:*", "route53:*",
           "cloudfront:*", "waf:*", "support:*", "budgets:*"
         ],
         "Resource": "*",
         "Condition": {
           "StringNotEquals": {
             "aws:RequestedRegion": ["ap-southeast-1", "us-east-1"]
           }
         }
       },
       {
         "Sid": "DenyRootUser",
         "Effect": "Deny",
         "Action": "*",
         "Resource": "*",
         "Condition": { "StringLike": { "aws:PrincipalArn": "arn:aws:iam::*:root" } }
       }
     ]
   }
   ```

   > Adjust the region list to yours. `ap-southeast-1` is Singapore (closest to the Philippines); keep `us-east-1` because some global services (IAM, CloudFront, Route 53) anchor there.

4. Attach the SCP to the **Clients** OU (Actions → Attach) so every client account inherits it. Never attach a restrictive SCP to the Root or the management account — you can lock yourself out.

### Step 6 — Enable IAM Identity Center for human logins

Instead of IAM users per account, use **IAM Identity Center** (formerly AWS SSO) for a single sign-on portal into every client account.

1. Open **IAM Identity Center** in the management account and choose **Enable**. Pick the same region you want as your identity home.
2. Under **Permission sets**, create sets such as `AdministratorAccess` and `ReadOnly`.
3. Under **Users** (or connect an external IdP like Google Workspace), create your team members.
4. Under **AWS accounts**, select a client account, **Assign users/groups**, pick the user/group and the permission set. Repeat per account, or assign at the OU level.
5. Share the **AWS access portal URL** with your team — they log in once and see every account they're entitled to.

### Step 7 — Billing and cost visibility

- Consolidated billing is automatic; the management account pays all invoices.
- In the management account, open **Billing → Cost Explorer** and group by **Linked account** to see spend per client.
- Set an **AWS Budget** per client account and enable **Cost Anomaly Detection** to catch runaway spend early.
- Consider enabling **tag policies** so all client accounts tag resources with `Client` and `Environment` for chargeback.

---

# Part B — Doing it via Terraform

Terraform makes the whole thing reproducible: onboarding a new client becomes a few lines of code and a `terraform apply`. Run all of this from the **management account** with admin credentials.

### Directory layout

```
aws-org/
├── bootstrap/                 # run FIRST, with local state, to create the backend
│   └── main.tf
├── backend.tf
├── providers.tf
├── organization.tf
├── accounts.tf
├── scp.tf
├── identity-center.tf
├── variables.tf
└── terraform.tfvars
```

### Step 0 — Bootstrap the state backend (the chicken-and-egg problem)

Terraform needs the **S3 bucket and DynamoDB lock table to already exist** before it can store state in them. You can't create them in the same configuration that uses them as a backend. There are two ways to solve this: create them once by hand (console or CLI), or create them with a tiny separate Terraform config that uses **local state**. Pick one.

**What each piece does:**

- **S3 bucket** — stores the `terraform.tfstate` file. Enable versioning (so you can roll back a corrupted state) and encryption, and block all public access.
- **DynamoDB table** — holds a lock so two people can't run `apply` at the same time and corrupt state. (On Terraform ≥ 1.10 you can skip DynamoDB and use S3-native locking with `use_lockfile = true` in the backend block — noted below.)

#### Option 1 — Create the backend via the Console UI

**S3 bucket:**

1. Open the **S3** console → **Create bucket**.
2. Name it globally-unique, e.g. `krunchie-tfstate` (bucket names are global across all of AWS).
3. Region: `ap-southeast-1` (Singapore).
4. Under **Bucket Versioning**, choose **Enable**.
5. Under **Default encryption**, keep **SSE-S3** (or choose SSE-KMS).
6. Leave **Block all public access** fully **on**.
7. Create the bucket.

**DynamoDB lock table:**

1. Open the **DynamoDB** console → **Create table**.
2. Table name: `terraform-locks`.
3. **Partition key:** `LockID` — type **String**. (This exact name is required by Terraform.)
4. Leave the default on-demand capacity; the table gets negligible traffic.
5. Create the table.

That's it — skip to `backend.tf` below.

#### Option 2 — Create the backend via Terraform (`bootstrap/main.tf`)

This small config uses **local state** (no backend block) to create the bucket and table. You run it once, then never touch it again.

```hcl
# bootstrap/main.tf
terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # No backend block here on purpose — this runs with LOCAL state.
}

provider "aws" {
  region = "ap-southeast-1"
}

# S3 bucket that will hold all remote state.
resource "aws_s3_bucket" "tfstate" {
  bucket = "krunchie-tfstate"

  # Guardrail: don't let a stray `terraform destroy` delete your state history.
  lifecycle {
    prevent_destroy = true
  }
}

# Keep every version of the state file so you can recover from corruption.
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt objects at rest.
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access — state can contain secrets.
resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking.
resource "aws_dynamodb_table" "tflocks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

output "state_bucket" {
  value = aws_s3_bucket.tfstate.id
}

output "lock_table" {
  value = aws_dynamodb_table.tflocks.name
}
```

Run it once:

```bash
cd bootstrap
terraform init
terraform apply        # creates the bucket + lock table using local state
cd ..
```

> Because `prevent_destroy` is set on the bucket, you can safely keep the local `bootstrap/terraform.tfstate` alongside the code (or commit the bootstrap outputs). The bucket and table now exist and are ready for the main config to use.

### `backend.tf` — remote state

```hcl
terraform {
  required_version = ">= 1.5"

  backend "s3" {
    bucket         = "krunchie-tfstate"
    key            = "aws-org/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-locks"   # or drop this and use S3 native locking (below)
    encrypt        = true
  }
}
```

This `bucket` and `dynamodb_table` must match exactly what you created in Step 0. After adding this file, run `terraform init` in the `aws-org/` root — Terraform detects the S3 backend and (if you had any local state) offers to **migrate** it to the bucket. Answer `yes`.

> **Skipping DynamoDB (Terraform ≥ 1.10):** modern Terraform can lock using a lockfile in S3 itself, so you don't need the table at all. Replace the `dynamodb_table` line with `use_lockfile = true`. If you go this route, you can delete the `aws_dynamodb_table` resource from `bootstrap/main.tf`.

### `providers.tf`

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
  # Uses your management-account admin credentials (env vars or a named profile)
}
```

### `organization.tf` — the org + OUs

```hcl
# Create the organization with all features enabled.
resource "aws_organizations_organization" "this" {
  feature_set = "ALL"

  # Enable the AWS services you want to manage org-wide.
  aws_service_access_principals = [
    "sso.amazonaws.com",          # IAM Identity Center
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
  ]

  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY",
  ]
}

# Top-level OUs
resource "aws_organizations_organizational_unit" "clients" {
  name      = "Clients"
  parent_id = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_organizational_unit" "sandbox" {
  name      = "Sandbox"
  parent_id = aws_organizations_organization.this.roots[0].id
}
```

> **Importing an existing org:** if you already created the organization in the console, don't recreate it — import it instead:
> `terraform import aws_organizations_organization.this o-xxxxxxxxxx`

### `variables.tf` and `terraform.tfvars` — define clients as data

```hcl
# variables.tf
variable "clients" {
  description = "Map of client accounts to create."
  type = map(object({
    email       = string
    environment = string
  }))
}
```

```hcl
# terraform.tfvars
clients = {
  "acme-prod" = {
    email       = "aws+acme-prod@krunchie.com"
    environment = "prod"
  }
  "acme-staging" = {
    email       = "aws+acme-staging@krunchie.com"
    environment = "staging"
  }
  "globex-prod" = {
    email       = "aws+globex-prod@krunchie.com"
    environment = "prod"
  }
}
```

### `accounts.tf` — one account per client, driven by the map

```hcl
resource "aws_organizations_account" "client" {
  for_each = var.clients

  name      = each.key
  email     = each.value.email
  parent_id = aws_organizations_organizational_unit.clients.id

  # Auto-created admin role the management account can assume.
  role_name = "OrganizationAccountAccessRole"

  # Keep IAM billing access on for the account's own admins.
  iam_user_access_to_billing = "ALLOW"

  # close_on_deletion controls what `terraform destroy` does:
  #   true  -> CloseAccount (works on org-created accounts; 90-day suspension)
  #   false -> RemoveAccountFromOrganization, which FAILS on org-created
  #            accounts with MEMBER_ACCOUNT_PAYMENT_INSTRUMENT_REQUIRED
  #            because they have no standalone payment method.
  # Set true if you want destroy to actually tear the account down.
  # If false, remove it from state instead: terraform state rm '...'
  close_on_deletion = true

  tags = {
    Client      = split("-", each.key)[0]
    Environment = each.value.environment
    ManagedBy   = "terraform"
  }

  lifecycle {
    # Email/name changes require account recreation; guard against accidents.
    ignore_changes = [role_name]
  }
}
```

Adding a new client is now just a new entry in `terraform.tfvars` followed by `terraform apply`.

### `scp.tf` — guardrails as code

```hcl
resource "aws_organizations_policy" "region_and_root_guardrail" {
  name        = "clients-baseline-guardrail"
  description = "Restrict client accounts to approved regions and block root usage."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyOutsideAllowedRegions"
        Effect   = "Deny"
        NotAction = [
          "iam:*", "sts:*", "organizations:*", "route53:*",
          "cloudfront:*", "waf:*", "support:*", "budgets:*"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = ["ap-southeast-1", "us-east-1"]
          }
        }
      },
      {
        Sid      = "DenyRootUser"
        Effect   = "Deny"
        Action   = "*"
        Resource = "*"
        Condition = {
          StringLike = { "aws:PrincipalArn" = "arn:aws:iam::*:root" }
        }
      }
    ]
  })
}

# Attach to the Clients OU so every client account inherits it.
resource "aws_organizations_policy_attachment" "clients_guardrail" {
  policy_id = aws_organizations_policy.region_and_root_guardrail.id
  target_id = aws_organizations_organizational_unit.clients.id
}
```

### `identity-center.tf` — SSO permission sets and assignments

IAM Identity Center must be **enabled once in the console** (there's no Terraform resource to enable the instance itself). After it's enabled, manage everything else in code:

```hcl
data "aws_ssoadmin_instances" "this" {}

locals {
  sso_instance_arn      = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id     = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
}

# A permission set granting admin.
resource "aws_ssoadmin_permission_set" "admin" {
  name             = "AdministratorAccess"
  instance_arn     = local.sso_instance_arn
  session_duration = "PT8H"
}

resource "aws_ssoadmin_managed_policy_attachment" "admin" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Reference an existing Identity Center group (create it in the console/IdP).
data "aws_identitystore_group" "engineers" {
  identity_store_id = local.identity_store_id
  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = "Engineers"
    }
  }
}

# Assign the Engineers group admin into every client account.
resource "aws_ssoadmin_account_assignment" "engineers_admin" {
  for_each = aws_organizations_account.client

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn

  principal_id   = data.aws_identitystore_group.engineers.group_id
  principal_type = "GROUP"

  target_id   = each.value.id
  target_type = "AWS_ACCOUNT"
}
```

### Apply workflow

```bash
terraform init
terraform plan -out=plan.tfout    # review carefully — account creation is high-impact
terraform apply plan.tfout
```

Order of operations Terraform handles for you: org → OUs → accounts → SCP attachment → SSO assignments. Account creation is slow (each takes ~1–2 min) and is **not** instantly reversible, so always review the plan.

---

## 4. Onboarding a new client — the repeatable checklist

**Console:** create account under `Clients` OU → move into a per-client OU → confirm the baseline SCP is inherited → assign the team's Identity Center group → set a budget.

**Terraform:** add the client block to `terraform.tfvars` → `terraform plan` → `terraform apply`. The SCP attachment and SSO assignment happen automatically because they're driven off the accounts map.

---

## 5. Best practices and gotchas

- **Never run workloads in the management account.** It holds org-wide admin and billing; keep its footprint tiny and its root user locked down with MFA and no access keys.
- **One unique email per account, and control the mailbox.** You'll need it for root password resets. A catch-all or plus-addressing scheme on your own domain is ideal.
- **Test SCPs on a sandbox OU first.** A misconfigured Deny can break deployments in every client account at once. SCPs never grant permissions — they only set the ceiling; IAM still has to allow the action.
- **Don't attach restrictive SCPs to Root or the management account** — you can lock yourself out of your own org.
- **Enable CloudTrail org-wide** (org trail from the management account) so every client account logs to a central, tamper-resistant bucket in a Log Archive account.
- **Turn on Cost Anomaly Detection and per-account budgets** early; a client's runaway Lambda or forgotten NAT gateway is your invoice.
- **Closing accounts is throttled.** AWS limits how many accounts you can close in a rolling period, so don't create throwaway client accounts casually.
- **`terraform destroy` fails with `MEMBER_ACCOUNT_PAYMENT_INSTRUMENT_REQUIRED`?** That happens when `close_on_deletion = false`: Terraform tries to make the account *leave* the org, which requires a standalone payment method the account doesn't have. Fix by either setting `close_on_deletion = true` (Terraform closes the account instead — apply the change, then destroy), or `terraform state rm 'aws_organizations_account.client["<name>"]'` to stop managing it while leaving the account in place. To genuinely make an org-created account standalone you must sign into it as root and add a payment method, contact info, and support plan first.
- **Keep Terraform state secure.** The org state describes your entire account topology — encrypt the bucket, lock it down, and restrict who can run applies.

---

## Sources

- [Creating a member account in an organization — AWS Organizations](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_create.html)
- [Best practices for member accounts — AWS Organizations](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_best-practices_member-acct.html)
- [Enable IAM Identity Center](https://docs.aws.amazon.com/singlesignon/latest/userguide/enable-identity-center.html)
- [Use Service Control Policies to control account instance creation — IAM Identity Center](https://docs.aws.amazon.com/singlesignon/latest/userguide/control-account-instance.html)
