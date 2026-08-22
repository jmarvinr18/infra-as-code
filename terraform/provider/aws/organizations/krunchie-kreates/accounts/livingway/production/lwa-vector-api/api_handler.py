"""
Private API test client.

A private REST API is unreachable from a laptop by design, so verifying it needs
a caller inside the VPC. This is that caller.

Deploy as a single-file Lambda in the same VPC, subnets and security group as
the tracker functions. Standard library only — no layer, no dependencies, no
packaging step. Paste it into the console editor and hit Deploy.

    Handler:  lambda_function.lambda_handler
    Timeout:  60 seconds
    Memory:   256 MB
    VPC:      same as the tracker Lambdas
    Layers:   none

Environment variables:

    API_ID       required   e.g. abc123xyz9
    STAGE        required   e.g. develop
    REGION       optional   defaults to ap-southeast-1
    VPCE_ID      optional   set ONLY if private DNS is disabled on the endpoint
    API_KEY      optional   registered agent key; without it, auth tests are skipped
    AGENT_ID     optional   defaults to clarvo-rag-v1

Invoke with an empty event {} to run the whole suite. Each check reports the
status code, latency, and a trimmed response body, so a failure tells you which
layer broke rather than just that something did.
"""

import json
import os
import ssl
import time
import urllib.error
import urllib.request

API_ID = os.environ.get("API_ID", "")
STAGE = os.environ.get("STAGE", "develop")
REGION = os.environ.get("REGION", "us-east-1")
VPCE_ID = os.environ.get("VPCE_ID", "")
API_KEY = os.environ.get("API_KEY", "")
AGENT_ID = os.environ.get("AGENT_ID", "clarvo-rag-v1")

TIMEOUT = 10


def base_url():
    """Two ways to address a private API.

    With private DNS enabled on the endpoint, the normal execute-api hostname
    resolves to the endpoint from inside the VPC. With it disabled, you must use
    the endpoint-specific hostname and identify the API by header instead.
    """
    if VPCE_ID:
        return f"https://{VPCE_ID}/{STAGE}"
    return f"https://{API_ID}.execute-api.{REGION}.amazonaws.com/{STAGE}"


def call(method, path, body=None, authenticated=True):
    url = f"{base_url()}{path}"

    headers = {"content-type": "application/json"}
    if VPCE_ID:
        # Required when addressing the endpoint hostname directly: without it
        # the endpoint has no way to know which API you mean.
        headers["x-apigw-api-id"] = API_ID
    if authenticated and API_KEY:
        headers["x-api-key"] = API_KEY
        headers["x-agent-id"] = AGENT_ID

    data = json.dumps(body).encode() if body is not None else None
    request = urllib.request.Request(url, data=data, headers=headers, method=method)

    started = time.time()
    try:
        with urllib.request.urlopen(request, timeout=TIMEOUT) as response:
            raw = response.read().decode("utf-8")
            return {
                "status": response.status,
                "ms": round((time.time() - started) * 1000),
                "body": _trim(raw),
            }

    except urllib.error.HTTPError as exc:
        # An HTTP error is still a reply — the network path worked. That makes
        # it far more informative than a timeout, so surface the body.
        return {
            "status": exc.code,
            "ms": round((time.time() - started) * 1000),
            "body": _trim(exc.read().decode("utf-8", errors="replace")),
            "diagnosis": _diagnose(exc.code),
        }

    except urllib.error.URLError as exc:
        reason = str(exc.reason)
        return {
            "status": "NO_RESPONSE",
            "ms": round((time.time() - started) * 1000),
            "error": reason,
            "diagnosis": _diagnose_network(reason),
        }

    except (TimeoutError, ssl.SSLError, OSError) as exc:
        return {
            "status": "NO_RESPONSE",
            "ms": round((time.time() - started) * 1000),
            "error": str(exc),
            "diagnosis": _diagnose_network(str(exc)),
        }


def _trim(text, limit=600):
    text = text.strip()
    return text if len(text) <= limit else text[:limit] + f"... [{len(text)} chars]"


def _diagnose(status):
    """Turn a status code into the thing to go and check.

    These three are the private-API failure modes, and they are easy to confuse
    because two of them look like an authentication problem and are not.
    """
    if status == 403:
        return (
            "Usually the resource policy: missing, or its aws:SourceVpce "
            "condition does not match this endpoint. Also check the API was "
            "redeployed after the policy was saved — policy changes are not "
            "live until a deployment. Less often, a wrong or missing x-api-key."
        )
    if status == 404:
        return (
            "Route not found. Check the resource path exists exactly, that the "
            "method is defined on it, and that the stage name in the URL "
            "matches the deployed stage."
        )
    if status == 500:
        return "The Lambda ran and raised. Check that function's CloudWatch logs."
    if status == 502:
        return (
            "Bad integration response. Almost always Lambda Proxy integration "
            "was left unticked, or the handler returned a shape without "
            "statusCode."
        )
    if status == 429:
        return "Stage throttling limit hit."
    return ""


def _diagnose_network(reason):
    lowered = reason.lower()
    if "name or service not known" in lowered or "nodename" in lowered:
        return (
            "DNS did not resolve. Either private DNS is off on the VPC endpoint "
            "(set VPCE_ID to use the endpoint hostname instead), or this "
            "function is not in the right VPC."
        )
    if "timed out" in lowered or "timeout" in lowered:
        return (
            "No route or blocked. Check this function is VPC-attached to the "
            "same VPC as the endpoint, and that the endpoint's security group "
            "allows inbound 443 from this function's security group."
        )
    if "certificate" in lowered:
        return "TLS problem — expected if you are calling the endpoint hostname without x-apigw-api-id."
    return "Nothing replied. Network path, not the API."


# ---------------------------------------------------------------------------
# Test suite
#
# Ordered cheapest-signal-first: the unauthenticated health route proves the
# network path without credentials, so a failure there means every later test
# would fail for the same reason.
# ---------------------------------------------------------------------------

def run_suite():
    results = {}

    results["1_health_unauthenticated"] = call(
        "GET", "/v1/health", authenticated=False
    )

    # Stop early if nothing replied — running nine more tests against a broken
    # network path produces nine identical errors and no extra information.
    if results["1_health_unauthenticated"]["status"] == "NO_RESPONSE":
        results["_stopped"] = (
            "Health did not reply, so the network path is broken. Fix that "
            "before interpreting anything else."
        )
        return results

    results["2_insights_authenticated"] = call("GET", "/v1/insights")

    results["3_adoption_by_division"] = call("GET", "/v1/metrics/adoption?days=30")

    results["4_trend"] = call("GET", "/v1/metrics/trend?days=30")

    results["5_themes"] = call("GET", "/v1/themes")

    # Proves the route actually reaches the check branch rather than falling
    # through, which is the failure the request_path fix addresses.
    results["6_feedback_check"] = call(
        "POST", "/v1/feedback/check", {"acf2_id": "eng0007"}
    )

    # The one that catches silent misrouting: if /submit is being handled by
    # check(), this returns a due/not-due object instead of an accepted flag.
    results["7_feedback_submit"] = call(
        "POST",
        "/v1/feedback/submit",
        {
            "acf2_id": "eng0007",
            "sentiment": "positive",
            "time_saved": 1.5,
            "barriers": "Sent by the private API test client",
            "value_signals": {"source": "test-client"},
        },
    )

    results["8_usage_ingest"] = call(
        "POST",
        "/v1/usage",
        {
            "events": [
                {
                    "event_id": f"evt_test_{int(time.time())}",
                    "agent_id": AGENT_ID,
                    "acf2_id": "testclient",
                    "platform": "test_client",
                    "business_group": "SLGS",
                    "division": "DevSecOps",
                    "event_type": "invocation",
                    "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
                    "metadata": {"source": "private-api-test"},
                }
            ]
        },
    )

    # Negative test. A private API that accepts an unauthenticated read is a
    # finding, so prove it refuses rather than assuming it does.
    results["9_rejects_missing_key"] = call(
        "GET", "/v1/insights", authenticated=False
    )

    return results


def summarise(results):
    passed, failed = [], []

    for name, result in results.items():
        if name.startswith("_"):
            continue
        status = result.get("status")

        if name == "9_rejects_missing_key":
            ok = status in (401, 403)
        else:
            ok = status == 200

        (passed if ok else failed).append(f"{name} [{status}]")

    return {"passed": passed, "failed": failed, "total": len(passed) + len(failed)}


def lambda_handler(event, context=None):
    if not API_ID:
        return {"ok": False, "error": "Set the API_ID environment variable"}

    # A single path can be requested for focused debugging:
    #   {"path": "/v1/health", "method": "GET", "auth": false}
    if isinstance(event, dict) and event.get("path"):
        return {
            "url": f"{base_url()}{event['path']}",
            "result": call(
                event.get("method", "GET"),
                event["path"],
                event.get("body"),
                event.get("auth", True),
            ),
        }

    results = run_suite()
    summary = summarise(results)

    return {
        "ok": not summary["failed"],
        "base_url": base_url(),
        "addressing": "vpc-endpoint-hostname" if VPCE_ID else "private-dns",
        "api_key_present": bool(API_KEY),
        "summary": summary,
        "results": results,
    }