import random, string
from locust import HttpUser, task, between

class YinklyUser(HttpUser):
    """
    A single user class that both creates links and
    follows existing short codes.
    """
    wait_time = between(1, 3)  # pause between tasks

    def on_start(self):
        # keep a list of codes we’ve generated
        self.codes = []

    @task(5)
    def create_link(self):
        # generate a random “long” URL
        long_url = "https://example.com/" + "".join(
            random.choices(string.ascii_letters + string.digits, k=12)
        )
        # hit your GKE create endpoint
        with self.client.post(
            "/create",
            json={"url": long_url},
            catch_response=True
        ) as resp:
            if resp.status_code == 200:
                try:
                    code = resp.json()["shortCode"]
                    self.codes.append(code)
                except Exception as e:
                    resp.failure(f"Bad JSON or missing shortCode: {e}")
            else:
                resp.failure(f"Unexpected status {resp.status_code}")

    @task(10)
    def redirect_link(self):
        # if we have no codes yet, skip
        if not self.codes:
            return
        code = random.choice(self.codes)
        # call your Cloud Function directly:
        self.client.get(
            f"https://europe-west1-plucky-dryad-459912-e4.cloudfunctions.net"
            f"/yinkly-redirect/{code}",
            catch_response=True
        )

