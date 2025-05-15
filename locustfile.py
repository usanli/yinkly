import random
import string
import re
from urllib.parse import urlparse
from locust import HttpUser, task, between, events

SHORTCODE_RE = re.compile(r"/([A-Za-z0-9]{6})$")

@events.init.add_listener
def on_locust_init(environment, **_kwargs):
    # shared store of all codes generated in this test run
    environment.codes = []

class YinklyUser(HttpUser):
    # point at your K8s LoadBalancer
    host = "http://130.211.102.77"
    wait_time = between(0.5, 1.5)

    @task(5)
    def create_and_store_code(self):
        # generate a random long URL
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

            # parse out the 6‐char code from the returned shortUrl
            try:
                data = resp.json()
                short_url = data["shortUrl"]
                path = urlparse(short_url).path
                m = SHORTCODE_RE.search(path)
                if not m:
                    raise ValueError(f"bad path {path}")
                code = m.group(1)
                # stash it for later redirect
                self.environment.codes.append(code)
            except Exception as e:
                resp.failure(f"JSON/parse error: {e}")

    @task(20)
    def redirect_code(self):
        # if nothing created yet, do nothing
        if not self.environment.codes:
            return

        code = random.choice(self.environment.codes)
        with self.client.get(
            f"/yinkly-redirect/{code}",
            catch_response=True,
            name="GET /yinkly-redirect"
        ) as resp:
            # should 302-redirect
            if resp.status_code != 302:
                resp.failure(f"redirect returned {resp.status_code}")
