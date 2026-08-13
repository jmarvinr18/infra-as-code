import hmac, hashlib, base64, sys

def smtp_password(secret, region):
    def sign(key, msg):
        return hmac.new(key, msg.encode("utf-8"), hashlib.sha256).digest()
    key = sign(("AWS4" + secret).encode("utf-8"), "11111111")
    key = sign(key, region)
    key = sign(key, "ses")
    key = sign(key, "aws4_request")
    key = sign(key, "SendRawEmail")
    return base64.b64encode(bytes([4]) + key).decode("utf-8")

secret, region = sys.argv[1], sys.argv[2]
print(smtp_password(secret, region))
