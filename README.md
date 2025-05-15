# Yinkly

A GCP-based URL shortener split across:
- **Compute Engine VM** for the database  
- **GKE container** for the admin UI & URL-generation API  
- **Cloud Function** for high-performance redirects  
- **Terraform** under `infra/` to provision everything with one command

## Getting Started

1. Clone this repo  
2. `cd infra && terraform init && terraform apply -auto-approve`  
3. Deploy your app and functions  
4. Visit the LoadBalancer IP to use the admin UI  
