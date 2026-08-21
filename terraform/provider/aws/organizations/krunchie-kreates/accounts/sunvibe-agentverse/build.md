# Agent Verse Hackathon — Challenge #1 Build Backlog

**Project:** AI Adoption & Feedback Trackers
**Window:** 7 days
**Target platforms for the demo:** Bedrock Agent / AgentCore, BMAD agent
**Explicitly out of scope this week:** Copilot Studio working demo (architecture still shows the path; we do not build it)

---

## The one rule for the week

Get a **walking skeleton** — one real event from one real agent into one real Postgres table — working on **Day 1**. Everything after that is widening a path that already exists. Teams that build components in isolation and integrate on Day 6 do not finish.

---

## Track assignment

The work splits into three parallel tracks. Collapse them onto fewer people if the team is small; the dependency arrows still hold.

| Track | Owns | Blocked by |
|---|---|---|
| **A — Backend** | API contract, Terraform, Lambda, Postgres schema, feedback logic | Nothing. Starts Day 1. |
| **B — Integrations** | SDK polish, CLI, AgentCore agent, BMAD agent | Needs API contract from A (Day 1 afternoon) |
| **C — Surface** | Dashboard, seed data, Bedrock theme summary, deck | Needs data shape from A (Day 1), real data from A+B (Day 3) |

---

# EPIC 1 — Central API & Data Store

### US-1.1 — Usage ingestion endpoint
> As an agent developer, I want a documented HTTP endpoint to POST usage events, so that I can integrate from any platform without deploying infrastructure.

**Acceptance criteria**
- `POST /v1/usage` accepts a batch: `{"events": [...]}`
- Returns `200` with a count of accepted events
- Rejects malformed payloads with `400` and a useful message
- OpenAPI spec published and matches the SDK's actual payload exactly

**Tasks**
- [ ] Write the OpenAPI spec first — it is the contract that unblocks Track B
- [ ] Terraform: API Gateway HTTP API + route + stage
- [ ] Lambda handler skeleton, returns 200 on any input
- [ ] Wire API Gateway → Lambda, confirm with `curl`
- [ ] Add request schema validation, return structured 400s

### US-1.2 — Central storage on Postgres + pgvector
> As a platform owner, I want events stored durably in one relational database, so that every agent shares one source of truth instead of per-team silos.

**Engine:** Aurora Serverless v2 for Postgres, `pgvector` enabled, accessed through the **RDS Data API**.

**Why the Data API matters more than it sounds:** Lambda plus Postgres is a connection-pool problem — concurrent invocations exhaust `max_connections` quickly. The Data API keeps the Lambdas out of the VPC entirely, which also means no NAT gateway for Bedrock egress and no VPC cold-start penalty. The alternative is Lambdas inside the VPC behind RDS Proxy, plus VPC endpoints for Bedrock. That is more moving parts than a week affords.

**Acceptance criteria**
- Schema created by a versioned migration in the repo, not clicked together in a console
- `pgvector` extension enabled with an index on the embedding column
- Two different `agent_id` values coexist without collision
- Every Lambda reaches the database through the Data API, not a raw connection string

**Schema**

| Table | Key columns | Notes |
|---|---|---|
| `usage_events` | `event_id UNIQUE`, `agent_id`, `acf2_id`, `platform`, `business_group`, `division`, `event_type`, `occurred_at`, `metadata jsonb` | Index on `(agent_id, occurred_at)` |
| `first_use` | PK `(agent_id, acf2_id)`, `first_use_at` | Written with `ON CONFLICT DO NOTHING` |
| `feedback_responses` | `response_id`, `agent_id`, `acf2_id`, `sentiment`, `time_saved`, `barriers text`, `value_signals jsonb`, `barrier_embedding vector(1024)`, `submitted_at` | Titan v2 default dimension |
| `barrier_themes` | `theme_id`, `agent_id`, `label`, `centroid vector(1024)`, `member_count`, `generated_at` | Populated by the clustering job |
| `insight_briefings` | `id`, `agent_id`, `generated_at`, `summary`, `insight`, `recommendation`, `citations jsonb` | Latest row per agent drives the panel |
| `agent_config` | `agent_id`, `api_key_hash`, `threshold_days`, `threshold_minutes` | Per-agent feedback threshold |

**The upside nobody will mention, so you should:** the aggregate queries this project exists to answer — adoption by Business Group and Division, active users over time, ranked barriers — are awkward key-value access patterns and trivial SQL. `GROUP BY division` replaces a scan plus a secondary index. The Metrics Lambda gets materially simpler.

**Tasks**
- [ ] Terraform Aurora Serverless v2 with Data API enabled and `min_capacity` as low as the account permits
- [ ] Migration creating the schema, `CREATE EXTENSION vector`, and the indexes
- [ ] Usage Lambda writes events via the Data API
- [ ] `first_use` insert uses `ON CONFLICT DO NOTHING` so the date never drifts forward
- [ ] Verify with events from two distinct agents

### US-1.3 — Security & resilience
> As a security reviewer, I want validation, authentication, least-privilege IAM and a dead-letter queue, so that failures are contained and visible rather than silent.

**Worth 10 rubric points on its own. Build it in now; retrofitting is how it gets dropped.**

**Acceptance criteria**
- API key required in header; missing or wrong key returns `401`
- Lambda execution role scoped to the cluster ARN and its Secrets Manager secret, no wildcards
- Duplicate `event_id` does not double-count
- Failed writes land in an SQS DLQ, not `/dev/null`
- API Gateway throttling configured

**Tasks**
- [ ] API key auth + per-agent key issuance, hashed in `agent_config`
- [ ] Idempotency: `UNIQUE(event_id)` plus `INSERT ... ON CONFLICT DO NOTHING` — simpler and stronger than the conditional-write equivalent
- [ ] Least-privilege IAM policy in Terraform
- [ ] SQS DLQ wired to the Lambda
- [ ] Throttle limits on the API Gateway stage
- [ ] **Write down one sentence per control** for the pitch — you must claim these out loud

### US-1.4 — Parameterised Terraform module
> As another agent team, I want to apply this module into my own repo without editing code, so that the reusability claim is real.

**Acceptance criteria**
- Module takes `agent_id`, environment, and table names as variables
- A second `terraform apply` with different variables produces a working second deployment
- README shows the module block a team copies

**Tasks**
- [ ] Extract hardcoded values into `variables.tf`
- [ ] Prove it: apply twice with different agent IDs
- [ ] Module usage README

---

# EPIC 2 — SDK & CLI

*The Python SDK is already written and tested. This epic is polish plus the BMAD path.*

### US-2.1 — SDK points at the real service
> As an agent developer, I want the SDK working against the deployed API, so that integration is real rather than a stub.

**Tasks**
- [ ] Update default endpoint to the deployed API Gateway URL
- [ ] Re-run `smoke_test.py` against real AWS, not the local stub
- [ ] Confirm the batch payload shape matches the OpenAPI spec exactly
- [ ] Publish to internal package index, or install from Git for the demo

### US-2.2 — SPIKE: how does a BMAD agent emit an event?
> **Do this Day 1. It is the largest unknown left on the board.**

BMAD agents are markdown/persona-driven and run inside an IDE — there is no Python process to decorate. Likely hooks, in order of preference:

1. **CLI command invoked as a task step** in the agent's markdown definition
2. **Wrapper script** around the agent invocation
3. **Git hook** on commits produced by the agent
4. **File watcher** on the agent's output directory

**Tasks**
- [ ] Open your actual BMAD agent definition and find where a shell command can run
- [ ] Pick the hook, write it down, tell Track A if it needs an API change
- [ ] Timebox to half a day — if none of the four work, fall back to a thin Python wrapper that invokes the BMAD agent and tracks around it

### US-2.3 — CLI entrypoint
> As a non-Python agent platform, I want a one-line shell command to record usage, so that I can integrate without importing anything.

**Acceptance criteria**
- `adoption-track usage --acf2-id abc1234 --bg SLGS --division DevSecOps` returns exit code 0
- Reads `ADOPTION_TRACKER_*` env vars for agent ID and key
- Exits 0 even when the API is unreachable — never fails the caller's pipeline
- `--platform bmad` sets the platform field

**Tasks**
- [ ] Add `cli.py` with `argparse`
- [ ] Register `[project.scripts] adoption-track = "adoption_tracker.cli:main"` in `pyproject.toml`
- [ ] Test: unreachable endpoint still exits 0
- [ ] Document in README

---

# EPIC 3 — Platform Integrations

### US-3.1 — Bedrock AgentCore agent emits usage
> As a leader, I want usage from our Bedrock agents visible centrally, so that I can see who is actually using them.

**Acceptance criteria**
- A running AgentCore or Bedrock agent calls `track_usage` on invocation
- Events appear in `usage_events` with `platform = "bedrock_agentcore"`
- Integration is genuinely three lines in the agent repo

**Tasks**
- [ ] Pick the agent — reuse an existing one rather than building a new one
- [ ] Add the three lines
- [ ] Invoke it, confirm the row lands
- [ ] **Time the integration and write the number down.** It is a demo talking point

### US-3.2 — BMAD agent emits usage
> As a leader, I want usage from BMAD agents visible in the same place, so that adoption is measured across platforms rather than per tool.

**Acceptance criteria**
- A BMAD agent run produces an event with `platform = "bmad"`
- It lands in the same table as the Bedrock events, no separate pipeline

**Tasks**
- [ ] Implement whichever hook the Day 1 spike chose
- [ ] Run the agent, confirm the row
- [ ] Confirm both platforms are queryable together in one scan

---

# EPIC 4 — Feedback Loop

### US-4.1 — Feedback becomes due after a threshold
> As a change manager, I want users asked for feedback a set time after first use, so that I hear from people who have actually formed an opinion.

**Acceptance criteria**
- `POST /v1/feedback/check` returns `{"due": false}` before the threshold
- Returns `{"due": true, "questions": [...]}` after it
- Threshold is configurable per agent, default 14 days
- A user who already answered is not asked again

**Tasks**
- [ ] Implement the check handler against the `FirstUse` table
- [ ] Per-agent threshold config in the `agent_config` table
- [ ] Suppress repeat surveys
- [ ] Unit-test the boundary: one day before, one day after

### US-4.2 — Demo-mode threshold
> **You cannot wait 14 days on stage. Without this, beat two of the demo is impossible.**

**Acceptance criteria**
- Threshold accepts minutes, not just days, when a demo flag is set
- Demo mode is explicit and obviously named — it must not look like a hack when a judge reads the code

**Tasks**
- [ ] Add `threshold_minutes` alongside `threshold_days` in agent config
- [ ] Document why it exists, in a comment a judge would find reassuring

### US-4.3 — Submitting feedback
> As an end user, I want to answer four short questions, so that my barriers are recorded without eating my time.

**Acceptance criteria**
- `POST /v1/feedback/submit` stores sentiment, time saved, barriers, value signals
- Returns `{"accepted": true}`
- Marks the user as answered so the survey stops firing

**Tasks**
- [ ] Implement the submit handler
- [ ] Wire the SDK's `submit_feedback` to it
- [ ] Confirm structured fields land as separate attributes, not one blob

---

# EPIC 5 — Dashboard

### US-5.1 — Adoption by org unit
> As a leader, I want adoption broken down by Business Group and Division, so that I can see where adoption is lagging.

**Acceptance criteria**
- Chart of active users by BG and Division
- Filterable by agent
- Visibly distinguishes a low-adoption division

**Tasks**
- [ ] Read-only Lambda endpoint returning aggregates
- [ ] Chart in QuickSight, or React + Chart.js if QuickSight shows any setup friction
- [ ] Make one division deliberately low in the seed data — the demo needs something to point at

### US-5.2 — Adoption trend
> As a leader, I want usage over time, so that I can tell growing adoption from stalled adoption.

**Acceptance criteria**
- Active users per day or week
- A flat or declining line is visually obvious

**Tasks**
- [ ] Time-bucketed aggregate endpoint
- [ ] Line chart
- [ ] Seed a division whose line goes flat after week two

### US-5.3 — Barriers surfaced
> As a change manager, I want the top reported barriers, so that I know which intervention to run.

**Acceptance criteria**
- Barriers displayed ranked by frequency
- This is the panel beat three of the demo points at

**Tasks**
- [ ] Aggregate feedback responses
- [ ] Display ranked barriers

### US-5.4 — Leadership briefing panel
> As a leader, I want the agent's briefing displayed alongside the charts, so that the interpretation and the evidence sit in one place.

**Acceptance criteria**
- Panel shows Summary, Insight and Recommendation as three labelled sections
- Displays when the briefing was generated
- Cited figures are visible next to the claims that use them
- Degrades gracefully when no briefing exists yet — an empty state, not an error

**Tasks**
- [ ] Panel component reading from the briefings endpoint
- [ ] Empty state and stale-briefing handling
- [ ] Regenerate control for the demo

### US-5.5 — Seed data
> **An empty dashboard is not a demo. Do this before you think you need it.**

**Tasks**
- [ ] Script that generates a few weeks of plausible usage across several BGs and divisions
- [ ] Include one clearly lagging division and one clear top barrier
- [ ] Keep it separate from live demo events so the live ones are visible landing
- [ ] Seed enough free-text barriers that the insight agent has real material to work from

---

# EPIC 6 — Leadership Insight Agent

*This is now the headline differentiator, not a cut candidate. It is also the only epic where a bad output is worse than no output — see US-6.3.*

### US-6.1 — Free-text barriers clustered into named themes
> As a change manager, I want raw complaints grouped into named themes, so that I get an intervention rather than a word cloud.

**This is where pgvector earns its place.** Two people writing "the docs are confusing" and "I couldn't find any documentation" are one theme, and string matching will never see it. Embed the barriers, cluster by cosine distance inside Postgres, then make a single Bedrock call to *name* each cluster — rather than asking an LLM to both discover and name themes from a wall of raw text.

**Acceptance criteria**
- Barriers embedded with Bedrock Titan Embeddings v2
- Semantically similar barriers land in the same `barrier_themes` row with a `member_count`
- One batched Bedrock call labels the clusters; never one call per response
- Themes queryable as agent tool output, ranked by `member_count`

**Tasks**
- [ ] Use `BedrockEmbeddings` with `amazon.titan-embed-text-v2:0` — **not** `HuggingFaceEmbeddings`, which drags `sentence-transformers` and CUDA into the container
- [ ] Embedding job: select rows where `barrier_embedding IS NULL`, embed, write back
- [ ] Cluster with a cosine-distance query against existing centroids; create a new theme when nothing falls within threshold
- [ ] One Bedrock call to label the clusters, capped batch size
- [ ] Sanity-check clustering against seed data — if unrelated barriers merge, tighten the distance threshold before blaming the model

### US-6.2 — Insight agent produces a leadership briefing
> As a leader, I want a written summary, insight and recommendation drawn from the adoption metrics, so that I get a decision rather than a chart I have to interpret myself.

**Acceptance criteria**
- Agent runs on AgentCore Runtime
- Reads data **only through tools** — `get_adoption_metrics` and `get_barrier_themes`, both backed by the existing Metrics Lambda. No direct database access from the agent
- Output has three named sections: Summary, Insight, Recommendation
- Recommendation is specific and actionable — "run a documentation clinic for Division X", not "consider improving adoption"

**Stack:** LangGraph for orchestration, `ChatBedrockConverse` from `langchain-aws` for the model, deployed to AgentCore Runtime. LangGraph and AgentCore are complementary — AgentCore is the hosting environment, LangGraph is what runs inside it.

**Graph shape** *(see the LangGraph flow diagram on the Miro board)*

| Node | Type | Purpose |
|---|---|---|
| `fetch_metrics` | tool | Adoption by BG/Division and trend, via Metrics Lambda |
| `fetch_themes` | tool | Ranked barrier themes from `barrier_themes`, via Metrics Lambda |
| `check_sufficiency` | conditional | Branch to honest-no-data when the dataset is too sparse |
| `draft_briefing` | LLM | Summary / Insight / Recommendation |
| `verify_grounding` | conditional | Every cited figure must exist in tool output |
| `revise` | LLM | Re-draft with the failed citations named, under a retry cap |
| `persist_briefing` | tool | Write to `insight_briefings` with `generated_at` |
| `honest_no_data` | terminal | Writes "insufficient data for a recommendation" |

**Tasks**
- [ ] Define the two tools against the existing `/v1/insights` aggregate endpoint
- [ ] Build the graph with a `TypedDict` state: metrics, themes, draft, failed_citations, retry_count
- [ ] **Pin `langchain`, `langchain-aws` and `langgraph` versions exactly.** LangChain has broken imports across minor versions before; a mid-week upgrade is a lost afternoon
- [ ] Deploy to AgentCore Runtime — build the container early, not on Day 6
- [ ] Write and iterate the system prompt until output is consistently specific
- [ ] Test against the seed data and confirm it finds the deliberately lagging division

**Container risk — check this on Day 4, not Day 6**
- [ ] Keep the image lean: `langchain-aws` and `langgraph` only, no `sentence-transformers` or anything that drags in CUDA
- [ ] Verify the image size against the AgentCore limit before you are depending on it
- [ ] Confirm cold start stays inside the initialization timeout

### US-6.3 — Every claim is grounded in a real number
> As a leader, I want each statement traceable to a metric, so that I can trust a briefing I might repeat to my own leadership.

**This is the risk that matters. A hallucinated "Division X adoption dropped 40%" delivered to executives is far worse than showing no briefing at all — and a judge will probe exactly this.**

**Acceptance criteria**
- Every claim in the briefing cites the figure behind it
- The agent cannot report on anything its tools did not return
- Bedrock Guardrails configured
- When the tools return insufficient data, the agent says so instead of inventing a trend

**The `verify_grounding` node is where LangGraph earns its place.** A chain cannot loop back to revise; a graph can. This is the conditional edge that justifies the framework choice — and it is worth saying exactly that in the pitch when a judge asks why LangGraph rather than a plain chain.

**Tasks**
- [ ] System prompt rule: cite the metric, never extrapolate beyond tool output
- [ ] **Verify programmatically, not with a second LLM call.** Parse the figures out of the draft and assert each one appears in the tool output. Deterministic, free, fast, and defensible to a judge — an LLM checking an LLM is not a control
- [ ] Cap the revise loop at two retries, then fail closed to `honest_no_data`
- [ ] Configure Bedrock Guardrails as the outer net
- [ ] Adversarial test: run against a nearly empty dataset and confirm it declines rather than fabricates
- [ ] Have a teammate fact-check one full briefing against the raw table, line by line

### US-6.4 — Briefings are cached, not generated per page load
> As the person paying the bill, I want briefings generated on a schedule, so that dashboard traffic does not translate into agent invocations.

**Acceptance criteria**
- `insight_briefings` stores generated briefings with `generated_at`
- Nightly EventBridge trigger regenerates
- Dashboard reads the latest cached briefing, and shows when it was generated
- An explicit "regenerate" control exists for the demo

**Tasks**
- [ ] `insight_briefings` table in the migration, plus a latest-row-per-agent query
- [ ] EventBridge scheduled rule → agent invocation
- [ ] Dashboard reads latest briefing, displays `generated_at`
- [ ] On-demand regenerate endpoint, rate-limited

### US-6.5 — The insight agent tracks its own usage
> As a judge, I want to see the tracker instrumenting the very agent that reads its data, so that the "works on any agent" claim is proven rather than asserted.

**Cheap to build, disproportionately good in the pitch. The insight agent is itself a Bedrock/AgentCore agent, so it takes the same three lines as any other.**

**Tasks**
- [ ] Add the SDK to the insight agent with `platform="bedrock_agentcore"`
- [ ] Confirm its runs appear in the same `usage_events` table
- [ ] Add one line to the pitch about it

---

# EPIC 7 — Demo & Pitch

### US-7.1 — The three beats work end to end
**Tasks**
- [ ] Beat 1: install the SDK into a repo nobody has touched, live, timed
- [ ] Beat 2: trigger usage from the Bedrock agent AND the BMAD agent; both land in the same table within seconds
- [ ] Beat 3: the insight agent's briefing names a specific action — "Division X adoption is flat since week two, top barrier is unclear documentation, run a documentation clinic" — with the figures cited beside it
- [ ] Beat 3b *(if time)*: show the insight agent's own run appearing in the usage table — the tracker tracking itself
- [ ] Run the whole thing three times without touching anything between runs
- [ ] Record a backup video — networks fail on stage

### US-7.2 — Pitch claims every rubric line
**Tasks**
- [ ] Update the deck: swap the Copilot Studio demo claim for "designed, not built this week"
- [ ] One sentence each for error handling, IAM, DLQ, idempotency, scaling
- [ ] Verify the cost figure against real account pricing
- [ ] Decide whether the Tech Lead's name stays on the closing slide

---

# Day-by-day

| Day | Track A — Backend | Track B — Integrations | Track C — Surface | **Milestone** |
|---|---|---|---|---|
| **1** | OpenAPI spec, Aurora Serverless v2 + Data API, migration, Lambda skeleton | BMAD spike, SDK endpoint update | Dashboard tech decision, seed data script | **One real event in one real table, via curl** |
| **2** | Validation, auth, idempotency, DLQ, IAM | SDK against real AWS, CLI entrypoint | Metrics Lambda aggregate endpoints | **SDK → AWS works end to end** |
| **3** | First-use tracking, feedback check, embedding job | Bedrock agent integrated, BMAD agent integrated | Charts rendering off real data | **Two platforms, one table** |
| **4** | Feedback submit, demo-mode threshold, config | Barrier theme summary, **container size spike** | LangGraph tools + graph skeleton against Metrics Lambda | **Survey fires on demand** |
| **5** | Briefings table, EventBridge trigger, parameterised module | LangGraph agent deployed to AgentCore, prompt iterated | BG/Division and trend charts, briefing panel | **Agent produces its first briefing** |
| **6** | Guardrails, grounding tests, caching | Fact-check a full briefing line by line, dogfooding | Briefing panel polished, deck updated | **Feature freeze at end of day** |
| **7** | Bugs only | Bugs only | Rehearse ×3, record backup | **Demo runs clean three times** |

---

# Cut list — in this order

If you are behind, cut from the top. Decide by end of Day 5, not on Day 7.

1. **The LangGraph deployment (US-6.2)** — if the AgentCore container fights you, run the same graph as a plain Lambda, or collapse it to an LCEL chain plus a programmatic grounding check. Keep `verify_grounding` whatever you cut; it is the part that protects you. The dashboard panel looks identical either way.
2. **Dogfooding (US-6.5)** — a good pitch line with zero demo dependency.
3. **Adoption trend chart (US-5.2)** — the BG/Division breakdown alone still answers "where is adoption lagging".
4. **Second Terraform apply proof (US-1.4)** — keep the parameterised module, drop the live second deployment.
5. **CLI polish** — a rough CLI that works beats a clean one that is not integrated.

**Never cut:** the DLQ, idempotency, least-privilege IAM, or the grounding rule in US-6.3. The first three are 10 rubric points for under an hour of work. The fourth is the difference between a briefing leadership can trust and one that embarrasses you in the Q&A.

---

# Definition of done

A story is done when:
- It works against deployed AWS, not a local stub
- Someone other than the author has run it
- It survives the endpoint being unreachable without crashing the caller
- There is one sentence written down explaining it, ready for the pitch

---

# Cost posture — this changed with Postgres

The old pitch line was "nothing bills while nobody is using it." That was true of on-demand DynamoDB and is **not automatically true of Postgres.** Adjust the claim rather than repeating one you can no longer defend.

- [ ] Set Aurora Serverless v2 `min_capacity` to the lowest the account allows, and confirm whether scale-to-zero is available to you — that is the difference between a few dollars for the week and a standing hourly charge
- [ ] Re-measure the total before repeating any figure on the cost slide
- [ ] Rewrite the claim honestly: the compute layer still scales to zero, the database now has a floor, and you should say what that floor is
- [ ] Do **not** put Lambdas in the VPC unless forced — a NAT gateway is a standing hourly cost of its own and would undercut the argument further

---

# Open decisions to settle Day 1

- [ ] **BMAD hook mechanism** — resolved by the US-2.2 spike
- [ ] **`agent_id` convention** — sync with the Tech Lead leading agent sharing and discoverability before the schema is frozen
- [ ] **Who passes BG and Division** — caller-passed this week, behind the `resolve_org_metadata()` seam
- [ ] **QuickSight or React** — decide by end of Day 1 and do not revisit
- [ ] **Aurora Serverless v2 or plain RDS** — Serverless v2 if the account allows a very low floor, `db.t4g.micro` if not. Decide before the migration is written
- [ ] **Confirm the Data API is available** for the chosen engine version. If it is not, you are into RDS Proxy plus VPC-attached Lambdas — a Day 1 decision, not a Day 5 discovery