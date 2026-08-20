# sunvibe-agentverse

Agent Verse hackathon, challenge #1 — **AI Adoption & Feedback Trackers**.

The backlog this is built against is in [build.md](build.md). The infrastructure
lives in [`modules/adoption_tracker`](../../../../modules/adoption_tracker),
which this account instantiates.

```
production/
├── terraform.tfvars              account values, shared by every component
├── tf-apply.sh                   apply, then apply the schema, then print outputs
├── tf-destroy.sh
└── adoption-tracker/
    ├── main.tf                   one module block
    ├── terraform.tfvars          everything that varies for this deployment
    ├── bootstrap-schema.sh        idempotent migration runner
    └── issue-api-key.sh           per-agent key issuance
```

## First apply

1. Put the member account id in `production/terraform.tfvars`. Nothing works
   until it is right — the provider assumes `OrganizationAccountAccessRole` in
   it.

2. Put the developer addresses in `pgvector_ec2_allowed_cidr_blocks`. That list
   is the only thing standing in front of the development database.

   ```bash
   curl -s https://checkip.amazonaws.com
   ```

3. Apply.

   ```bash
   cd production && ./tf-apply.sh
   ```

   This applies the stack, then applies the schema. The migration is idempotent,
   so it runs on every apply rather than only the first — a schema change never
   needs a separate, forgettable step.

4. Issue a key for the demo agent. `2` here is `threshold_minutes`, which is
   what makes a survey fire on stage instead of a fortnight later.

   ```bash
   cd adoption-tracker && ./issue-api-key.sh sunvibe-demo 14 2
   ```

5. Confirm one real event lands in one real table.

   ```bash
   API="$(terraform output -raw api_endpoint)"

   curl -sX POST "$API/v1/usage" \
     -H "x-api-key: $ADOPTION_TRACKER_API_KEY" \
     -H "x-agent-id: sunvibe-demo" \
     -H "content-type: application/json" \
     -d '{"events":[{"event_id":"evt-1","acf2_id":"abc1234","platform":"bedrock_agentcore","business_group":"SLGS","division":"DevSecOps"}]}'

   curl -s "$API/v1/insights?days=30" -H "x-api-key: $ADOPTION_TRACKER_API_KEY" -H "x-agent-id: sunvibe-demo"
   ```

   Send the same `event_id` twice. The second call reports it as a duplicate
   and the adoption number does not move — that is the idempotency claim, and
   it is worth demonstrating rather than asserting.

## Endpoints

| Route | Function | Notes |
|---|---|---|
| `GET /health` | metrics | Unauthenticated; answers while the cluster is paused |
| `POST /v1/usage` | usage | Batch: `{"events": [...]}`, max 500 |
| `POST /v1/feedback/check` | feedback | `{"due": false}` before the threshold |
| `POST /v1/feedback/submit` | feedback | Stores sentiment, time saved, barriers, value signals |
| `GET /v1/insights` | metrics | Everything the dashboard needs, plus the cached briefing |
| `GET /v1/metrics/adoption` | metrics | By business group and division |
| `GET /v1/metrics/trend` | metrics | Active users per week |
| `GET /v1/themes` | metrics | Barrier themes ranked by member count |
| `POST /v1/insights/regenerate` | briefing | The demo's regenerate control; throttled hard |

## The development database

`create_pgvector_ec2 = true` runs Postgres + pgvector in Docker on one EC2
instance. It is the fallback for the week: if the Data API turns out to be
unavailable for the chosen engine version, or a cluster-side quota bites, point
the functions at this host and keep building.

It is also what a developer opens in TablePlus or DBeaver, which is why it has
a public address at all.

```bash
cd production/adoption-tracker
terraform output -raw pgvector_ec2_connection_string          # paste into the client
aws ssm start-session --target "$(terraform output -raw pgvector_ec2_instance_id)"
```

No SSH key is needed — the host has `AmazonSSMManagedInstanceCore` and port 22
stays closed unless `pgvector_ec2_key_name` is set. Once you are on it:

```bash
cd /opt/pgvector && docker compose ps && docker compose logs -f postgres
```

Switching the functions over needs a psycopg layer as well, because the driver
is not in the Lambda runtime:

```hcl
use_pgvector_ec2_for_lambdas = true
lambda_layers                = ["arn:aws:lambda:ap-southeast-1:...:layer:psycopg:1"]
```

The module refuses the apply if only one of the two is set, rather than letting
it fail as an `ImportError` on the first invocation after the switch.

## The insight agent

`create_insight_agent` stays false until the container image is in ECR — the
runtime cannot start from an empty repository, and day six is a bad time to
find that out.

```bash
terraform output -raw ecr_repository_url    # build and push the LangGraph image here
terraform apply -var create_insight_agent=true
```

## Cost

The compute layer scales to zero. The database does not, automatically.

`db_min_capacity = 0` lets the cluster pause when idle. Confirm the account
permits it on the first apply — if it does not, raise the floor and say what
the floor costs on the cost slide rather than repeating a claim that is no
longer true. Keeping the Lambdas out of the VPC is part of the same posture: a
NAT gateway would be a standing hourly charge of its own.

The EC2 host is a small standing cost while it exists. Stop it overnight — the
Elastic IP means the connection string survives a stop/start.
