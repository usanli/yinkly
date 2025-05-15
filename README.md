# Yinkly

A GCP-based URL shortener split across:

* **Compute Engine VM** for the database
* **GKE container** for the admin UI & URL-generation API
* **Cloud Function** for high-performance redirects
* **Terraform** under `infra/` to provision everything with one command

## Prerequisites

* [gcloud CLI](https://cloud.google.com/sdk/docs/install) installed & authenticated
* [kubectl](https://kubernetes.io/docs/tasks/tools/) installed
* [Terraform](https://www.terraform.io/downloads.html) v1.2+ installed
* Docker installed & configured to push to your GCP project’s Artifact Registry or Container Registry
* A billing‐enabled GCP project

## Deployment

1. **Clone the repo**

   ```bash
   git clone https://github.com/usanli/yinkly.git
   cd yinkly
   ```

2. **Provision infra with Terraform**

   ```bash
   cd infra
   terraform init
   terraform apply -auto-approve
   ```

   This will create:

   * A Compute Engine VM running PostgreSQL
   * A GKE cluster (with node pool)
   * A serverless Cloud Function for redirects

3. **Build & push the admin UI image**

   ```bash
   cd ../app/backend
   docker build -f Dockerfile -t gcr.io/$GOOGLE_CLOUD_PROJECT/yinkly-admin:latest .
   docker push gcr.io/$GOOGLE_CLOUD_PROJECT/yinkly-admin:latest
   ```

4. **Deploy to Kubernetes**

   ```bash
   cd ../../k8s
   kubectl apply -f deployment.yaml
   kubectl apply -f service.yaml
   ```

5. **Verify everything is running**

   ```bash
   # Wait for pods
   kubectl rollout status deployment/yinkly-admin

   # Get the LoadBalancer IP
   kubectl get svc yinkly-admin
   ```

   Visit the external IP on port 80 to use the Yinkly UI.

6. **Deploy (or redeploy) Cloud Function**
   If not already done by Terraform, from the repo root:

   ```bash
   gcloud functions deploy yinkly-redirect \
     --region $GOOGLE_CLOUD_REGION \
     --runtime nodejs20 \
     --trigger-http \
     --allow-unauthenticated \
     --entry-point handleRedirect \
     --set-env-vars DB_HOST=<VM_IP>,DB_PORT=5432,DB_USER=shortener,DB_PASSWORD=<pw>,DB_NAME=yinklydb
   ```

## Load Testing

Inside the repo root:

```bash
locust -f locustfile.py --host http://<YOUR_LB_IP>
```

Point your browser to `http://localhost:8089` to start the test and watch your HPA scale pods.

## Teardown

When you’re done, you can tear everything down in one go:

1. **Delete Kubernetes resources**

   ```bash
   kubectl delete -f k8s/deployment.yaml
   kubectl delete -f k8s/service.yaml
   ```

2. **Destroy the Terraform-managed infra**

   ```bash
   cd infra
   terraform destroy -auto-approve
   ```

3. **(Optional) Delete the image**

   ```bash
   gcloud container images delete gcr.io/$GOOGLE_CLOUD_PROJECT/yinkly-admin:latest --quiet
   ```

This will remove your VM, GKE cluster, and Cloud Function, leaving no active resources behind.
