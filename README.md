# AutoHeal Deploy — Self-Healing CI/CD Pipeline

A full-stack Smart Task Manager web application with a complete, production-ready DevOps infrastructure supporting automated CI/CD deployment via Jenkins, Docker containerization, AWS EC2 hosting, Terraform infrastructure provisioning, and a self-healing auto-recovery mechanism.

## Architecture Diagram

```text
+-------------------+       +-----------------------+       +-------------------+
|                   |       |                       |       |                   |
|  GitHub Repo      +------>+   Jenkins CI/CD       +------>+   AWS EC2         |
|  (Source Code)    | Push  |   (Build & Deploy)    | SSH   |   (App Server)    |
|                   |       |                       |       |                   |
+-------------------+       +-----------------------+       +---------+---------+
                                                                      |
                                                                      v
                                                            +---------+---------+
                                                            |                   |
                                                            |   Docker Engine   |
                                                            |                   |
                                                            |  +-------------+  |
                                                            |  | AutoHeal App|  |
                                                            |  +------+------+  |
                                                            |         |         |
                                                            +---------+---------+
                                                                      |
                                                            +---------+---------+
                                                            |                   |
                                                            |  health_monitor.sh|
                                                            |  (Self-Healing)   |
                                                            |                   |
                                                            +-------------------+
```

## Prerequisites
- Node.js (for local dev)
- Docker & Docker Compose
- Terraform
- Jenkins (for CI/CD)
- AWS Account

## Local Setup Instructions
### Option A: Docker Compose (recommended)
1. Copy `.env.example` to `.env` and set your MongoDB Atlas `MONGO_URI`.
2. Run: `docker compose up -d --build`
3. Access at `http://localhost:3000`

### Option B: Node.js (manual)
1. Clone the repository: `git clone https://github.com/YOUR_USERNAME/autoheal-deploy.git`
2. Navigate to the app directory: `cd autoheal-deploy/app`
3. Install dependencies: `npm install`
4. Copy `.env.example` to `.env` and configure your MongoDB Atlas `MONGO_URI`.
5. Run the application: `npm start`
6. Access at `http://localhost:3000`

## AWS Deployment Steps (Terraform)
1. Navigate to the `terraform/` directory.
2. Initialize Terraform: `terraform init`
3. Update `terraform.tfvars` with your `mongo_uri` and `session_secret`.
4. Review the execution plan: `terraform plan`
5. Apply the configuration: `terraform apply`
6. Access your EC2 instance using the printed `app_url` output.

## Jenkins Setup Steps
1. Install Jenkins on your server (handled by our Terraform userdata script).
2. Configure a new Pipeline job pointing to your GitHub repository.
3. Ensure Docker pipeline plugins are installed.
4. Set **MONGO_URI** in Jenkins (Manage Jenkins → Configure System → Global properties → Environment variables). Optional: set **SESSION_SECRET**.
5. The `Jenkinsfile` at the root of the project will handle testing, building, and deploying the Docker container.

## Self-Healing Demo Instructions
1. Verify the app is running: `curl http://localhost:3000/health`
2. Deliberately stop the container to simulate a failure: `docker stop autoheal-app`
3. Wait for up to 20 seconds for the timer to run the `health_monitor.sh` script.
4. Check the logs at `/var/log/autoheal.log` to see the failure detected and restart triggered.
5. Verify the app is back up: `curl http://localhost:3000/health`
