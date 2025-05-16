# Yinkly

A GCP-based URL shortener split across:

* **Compute Engine VM** for the database
* **GKE container** for the admin UI & URL-generation API
* **Cloud Function** for high-performance redirects
* **Terraform** under `infra/` to provision everything with one command

## Service Endpoint

Your Yinkly service is live at: **[http://34.76.62.241/](http://34.76.62.241/)**

## Prerequisites

* [gcloud CLI](https://cloud.google.com/sdk/docs/install) installed & authenticated
* [kubectl](https://kubernetes.io/docs/tasks/tools/) installed
* [Terraform](https://www.terraform.io/downloads.html) v1.2+ installed
* Docker installed & configured to push to your GCP project’s Artifact Registry or Container Registry
* A billing‐enabled GCP project

## Deployment

### 1. Clone the repo

```bash
git clone https://github.com/usanli/yinkly.git
cd yinkly
```

### 2. Provision infra with Terraform

```bash
cd infra
terraform init
terraform apply -auto-approve
```

This will create:

* A Compute Engine VM running PostgreSQL
* A GKE cluster (with node pool)
* A serverless Cloud Function for redirects

### 3. Build & push the admin UI image

```bash
cd ../app/backend
docker build -f Dockerfile -t gcr.io/$GOOGLE_CLOUD_PROJECT/yinkly-admin:latest .
docker push gcr.io/$GOOGLE_CLOUD_PROJECT/yinkly-admin:latest
```

### 4. Deploy to Kubernetes

```bash
cd ../../k8s
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

#### Horizontal Pod Autoscaling

The GKE service is configured to scale between **1 and 10 pods** based on average CPU utilization (target: 50%). You can customize these limits in `k8s/hpa.yaml`.

### 5. Verify everything is running

```bash
# Wait for pods to be ready
kubectl rollout status deployment/yinkly-admin

# Get the LoadBalancer IP
echo "http://$(kubectl get svc yinkly-admin -o jsonpath='{.status.loadBalancer.ingress[0].ip}')/"
```

Visit the external IP on port 80 (e.g. [http://34.76.62.241/](http://34.76.62.241/)) to use the Yinkly UI.

### 6. Deploy (or redeploy) Cloud Function

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

## Load Testing with Locust

Inside the repo root:

```bash
locust -f locustfile.py --host http://34.76.62.241/
```

Point your browser to `http://localhost:8089` to start the test, then monitor:

* The **Locust** dashboard for request rates and response times
* The **GKE HorizontalPodAutoscaler** via:

  ```bash
  kubectl get hpa yinkly-admin -n default
  kubectl describe hpa yinkly-admin -n default
  ```
* The **pod count** with:

  ```bash
  kubectl get pods -l app=yinkly-admin -n default
  ```

This setup allows your service to handle bursts of traffic by scaling up to 10 replicas automatically.

## Teardown

When you’re done, tear everything down:

1. **Delete Kubernetes resources**

   ```bash
   kubectl delete -f k8s/deployment.yaml
   kubectl delete -f k8s/service.yaml
   kubectl delete -f k8s/hpa.yaml
   ```

2. **Destroy Terraform-managed infra**

   ```bash
   cd infra
   terraform destroy -auto-approve
   ```

3. **(Optional) Delete the Docker image**

   ```bash
   gcloud container images delete gcr.io/$GOOGLE_CLOUD_PROJECT/yinkly-admin:latest --quiet
   ```

This will remove your VM, GKE cluster, HPA, and Cloud Function, leaving no active resources behind.
