"""
Contract check: does the SDK still send what the OpenAPI spec documents?

Run this in CI, or by hand after any payload change. It boots a throwaway
server, drives the real SDK against it, and diffs the captured payloads
against the spec. Catches drift the moment it appears rather than at
integration time.

    pip install openapi-spec-validator
    python verify_contract.py path/to/openapi.yaml path/to/sdk/src
"""
import json
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, HTTPServer
from openapi_spec_validator import validate
from openapi_spec_validator.readers import read_from_filename

spec_path = sys.argv[1] if len(sys.argv) > 1 else "openapi.yaml"
sdk_path = sys.argv[2] if len(sys.argv) > 2 else "../adoption-tracker-sdk/src"
sys.path.insert(0, sdk_path)

from adoption_tracker import Tracker  # noqa: E402

spec, _ = read_from_filename(spec_path)
validate(spec)
print("spec is structurally valid")

CAPTURED = {}


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *a):
        pass

    def do_POST(self):
        n = int(self.headers.get("Content-Length", 0))
        CAPTURED[self.path] = json.loads(self.rfile.read(n) or "{}")
        CAPTURED[self.path + ":headers"] = dict(self.headers)
        body = json.dumps({"due": True, "questions": [
                          "sentiment"], "accepted": True}).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


srv = HTTPServer(("127.0.0.1", 8123), Handler)
threading.Thread(target=srv.serve_forever, daemon=True).start()

tracker = Tracker(
    agent_id="contract-check", api_key="k",
    endpoint="http://127.0.0.1:8123",
    platform="bedrock_agentcore", flush_interval=0.2,
)
tracker.track_usage(acf2_id="abc1234",
                    business_group="SLGS", division="DevSecOps")
time.sleep(0.6)
tracker.flush()
time.sleep(0.3)
tracker.feedback_due("abc1234")
tracker.submit_feedback(acf2_id="abc1234", sentiment=4,
                        time_saved="2h/week", barriers="x")
tracker.close()
srv.shutdown()


def schema(name):
    return spec["components"]["schemas"][name]


failures = []


def compare(label, sent, schema_name):
    s = schema(schema_name)
    documented = set(s["properties"])
    undocumented = set(sent) - documented
    unsent_required = set(s.get("required", [])) - set(sent)
    if undocumented:
        failures.append(
            f"{label}: SDK sends undocumented field(s) {sorted(undocumented)}")
    if unsent_required:
        failures.append(
            f"{label}: spec requires {sorted(unsent_required)} but SDK omits them")
    print(f"{label}: {len(sent)} fields checked")


compare("POST /v1/usage", CAPTURED["/v1/usage"]["events"][0], "UsageEvent")
compare("POST /v1/feedback/check",
        CAPTURED["/v1/feedback/check"], "FeedbackCheckRequest")
compare("POST /v1/feedback/submit",
        CAPTURED["/v1/feedback/submit"], "FeedbackSubmission")

header_name = spec["components"]["securitySchemes"]["ApiKeyAuth"]["name"]
headers = CAPTURED["/v1/usage:headers"]
if not any(k.lower() == header_name.lower() for k in headers):
    failures.append(f"auth: SDK does not send {header_name}")

print()
if failures:
    print("CONTRACT DRIFT:")
    for f in failures:
        print(" -", f)
    sys.exit(1)
print("CONTRACT MATCHES SDK")
