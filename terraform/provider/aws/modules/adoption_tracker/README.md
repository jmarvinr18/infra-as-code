# adoption_tracker

Central usage-and-feedback tracking for internal AI agents: one HTTP API, five
Lambdas, one Aurora Serverless v2 Postgres cluster with pgvector, and a Bedrock
agent that reads the aggregates back out through tools.

```
capture   SDK · CLI · raw HTTP
ingest    API Gateway HTTP API — API key in a header, throttled per stage
process   usage · feedback · metrics · embedding · briefing
store     Aurora Serverless v2 + pgvector, over the RDS Data API
insight   AgentCore runtime running LangGraph, behind a Bedrock guardrail
surface   whatever reads GET /v1/insights
```

## Copying it into your own repo

Everything that distinguishes one deployment from another is a variable, so a
second apply stands up a parallel deployment rather than colliding with the
first.

```hcl
module "adoption_tracker" {
  source = "../../modules/adoption_tracker"

  name_prefix      = "my-team-tracker"
  environment      = "production"
  default_agent_id = "my-agent"

  region     = data.aws_region.current.region
  account_id = data.aws_caller_identity.current.account_id

  # Only needed when sharing a database with another deployment.
  table_names = {
    usage_events = "my_team_usage_events"
    first_use    = "my_team_first_use"
  }

  tags = { Team = "platform" }
}
```

`name_prefix` covers the API, functions, roles, queue, cluster and schedules.
`table_names` covers the schema, and reaches both the migration and the
functions from the same place — they cannot drift apart.

## Why the Data API

Lambda plus Postgres is a connection-pool problem before it is anything else:
concurrent invocations exhaust `max_connections` quickly, and the usual fixes
are RDS Proxy plus VPC-attached functions plus VPC endpoints for Bedrock.

The Data API is a regional HTTPS endpoint, so the functions stay out of the VPC
entirely. No ENI cold start, no NAT gateway standing charge for Bedrock egress,
and no pool to exhaust. The cost is that every statement is an API call rather
than a cursor, which for aggregate queries and small batched writes is a
trade worth making.

Two things follow from it and are worth knowing before the first apply:

- **Confirm the Data API is available for your engine version.** If it is not,
  you are into RDS Proxy and VPC-attached Lambdas, and that is a day-one
  decision rather than a day-five discovery.
- **The first call after an idle period can fail** while a paused Serverless v2
  cluster resumes. The clients here retry adaptively; anything else calling the
  cluster should too.

## The development fallback

`create_pgvector_ec2` puts Postgres and pgvector in a Docker container on one
EC2 instance — same engine, same extension, ordinary connection string. It
exists so that a Data API quota, an unavailable engine version or any other
cluster-side blocker cannot stall the Lambda work.

It is reachable from outside the VPC because both of its callers are: a
developer's SQL client and a Lambda that is not VPC-attached. That makes
`pgvector_ec2_allowed_cidr_blocks` the only thing in front of the database, so
put real addresses in it.

```bash
terraform output -raw pgvector_ec2_connection_string   # paste into TablePlus
aws ssm start-session --target "$(terraform output -raw pgvector_ec2_instance_id)"
```

Pointing the functions at it needs two settings together, and the module
refuses the apply if only one is present:

```hcl
use_pgvector_ec2_for_lambdas = true
lambda_layers                = ["arn:aws:lambda:...:layer:psycopg:1"]
```

The layer is not optional — psycopg is not in the Lambda runtime, which is the
whole reason the Data API path needs no dependencies at all.

## Controls worth naming

These are cheap to build and expensive to retrofit, so they are in from the
start rather than added at the end.

| Control | Where it lives |
|---|---|
| Idempotency | `event_id` is UNIQUE and every insert is `ON CONFLICT DO NOTHING`. A retried batch cannot double-count. |
| Least privilege | One role per function, scoped to the cluster ARN and its secret. No wildcard resources; the metrics function cannot invoke Bedrock at all. |
| Dead-letter queue | Request handlers push failed writes to SQS explicitly — Lambda's own `dead_letter_config` only covers async invocations. Scheduled functions and EventBridge targets use it too. |
| Throttling | Stage-level limits, plus a much tighter per-route limit on `POST /v1/insights/regenerate`, which costs one agent invocation per call. |
| API key auth | SHA-256 in `agent_config`, compared in constant time. The key itself is never stored. |
| Grounding | The agent reads only through tools and has no database permissions, so it cannot report on data its tools did not return. The Bedrock guardrail is the outer net; the citation check in the graph is the real control. |

## Sequencing the AgentCore runtime

The runtime cannot start from an empty ECR repository, so `create_insight_agent`
defaults to false. Build the image early:

```bash
terraform apply                                    # create_insight_agent = false
terraform output -raw ecr_repository_url           # push the LangGraph image here
# ... docker build && docker push ...
terraform apply -var create_insight_agent=true
```

## Cost posture

The compute layer scales to zero. The database does not, automatically.

`db_min_capacity = 0` lets the cluster pause when idle, which is the difference
between a few dollars for a week and a standing hourly charge — but not every
account permits it. Check on the first apply, and if it is refused, raise the
floor and say what the floor costs rather than repeating a scale-to-zero claim
you can no longer defend.

Keeping the Lambdas out of the VPC is part of the same posture: a NAT gateway
is a standing hourly cost of its own.
