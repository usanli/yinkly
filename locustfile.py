import random
import string
import re
import time
from urllib.parse import urlparse
from locust import HttpUser, task, between, events

SHORTCODE_RE = re.compile(r"/([A-Za-z0-9]{6})$")

@events.init.add_listener
def on_locust_init(environment, **_kwargs):
    environment.redirect_urls = []

class YinklyUser(HttpUser):
    # POST goes to GKE, GET goes to Cloud Function
    host = "http://34.76.62.241"  # Your LoadBalancer IP
    wait_time = between(0.5, 1.5)

    @task(5)
    def create_and_store_code(self):
        long_url = "https://locust.example.com/" + "".join(
            random.choices(string.ascii_letters + string.digits, k=12)
        )
        with self.client.post(
            "/create",
            json={"url": long_url},
            catch_response=True,
            name="POST /create"
        ) as resp:
            if resp.status_code != 200:
                resp.failure(f"create returned {resp.status_code}")
                return

            try:
                data = resp.json()
                short_url = data["shortUrl"]
                path = urlparse(short_url).path
                m = SHORTCODE_RE.search(path)
                if not m:
                    raise ValueError(f"bad path: {path}")
                code = m.group(1)
                # Short wait to ensure DB is ready before redirect test
                time.sleep(0.5)
                self.environment.redirect_urls.append(code)
            except Exception as e:
                resp.failure(f"parse error: {e}")

@task(20)
def redirect_code(self):
    if not self.environment.redirect_urls:
        return

    code = random.choice(self.environment.redirect_urls)
    self.client.get(
        f"/yinkly-redirect/{code}",
        name="GET CloudFunction /yinkly-redirect"
    )

