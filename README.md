# 🚀 CloudOps Health Monitor

> **Cloud-native Flask application with automated AWS infrastructure provisioning and Jenkins CI/CD deployment**

[![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python)](https://www.python.org/)
[![Flask](https://img.shields.io/badge/Flask-3.1-black?logo=flask)](https://flask.palletsprojects.com/)
[![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED?logo=docker)](https://www.docker.com/)
[![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-D24939?logo=jenkins)](https://www.jenkins.io/)
[![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazonaws)](https://aws.amazon.com/)
[![GitHub](https://img.shields.io/badge/GitHub-Version%20Control-181717?logo=github)](https://github.com/)

---

## 📌 Overview

**CloudOps Health Monitor** is a containerized Flask application deployed on **AWS EC2** using **Terraform** and automated through a **Jenkins CI/CD pipeline**.

The project demonstrates an end-to-end DevOps workflow where source code is maintained in GitHub, Jenkins builds the Docker image, deploys the application to multiple AWS EC2 instances through SSH, and automatically verifies the deployment using health-check endpoints.

### ✨ Key Highlights

- 🐍 Flask-based health monitoring application
- 🐳 Docker containerization
- ☁️ AWS EC2 deployment
- 🏗️ Infrastructure as Code with Terraform
- 🔄 Jenkins CI/CD automation
- 🔐 SSH-based automated deployment
- 🌐 Custom AWS VPC and public subnets
- 🖥️ Deployment across two EC2 instances
- ❤️ Automated post-deployment health checks
- 📦 GitHub-based source control

---

## 🏗️ Architecture

```text
                        ┌─────────────────────┐
                        │       GitHub        │
                        │  Source Repository  │
                        └──────────┬──────────┘
                                   │
                                   ▼
                        ┌─────────────────────┐
                        │      Jenkins       │
                        │      CI / CD        │
                        └──────────┬──────────┘
                                   │
                         Docker Build & Deploy
                                   │
                 ┌─────────────────┴─────────────────┐
                 │                                   │
                 ▼                                   ▼
        ┌─────────────────┐                 ┌─────────────────┐
        │     AWS EC2     │                 │     AWS EC2     │
        │    Instance 1   │                 │    Instance 2   │
        │                 │                 │                 │
        │ Docker          │                 │ Docker          │
        │ Flask App       │                 │ Flask App       │
        └────────┬────────┘                 └────────┬────────┘
                 │                                   │
                 └─────────────────┬─────────────────┘
                                   │
                                   ▼
                         ┌───────────────────┐
                         │   Health Check    │
                         │   /health → 200   │
                         └───────────────────┘
```

---

## ⚙️ Technology Stack

### Application
- Python 3.12
- Flask
- REST-style health endpoints

### Containerization
- Docker
- Dockerfile
- Docker image and container management

### Cloud
- AWS EC2
- Amazon Linux 2023
- Amazon VPC
- Public Subnets
- Internet Gateway
- Security Groups

### Infrastructure as Code
- Terraform

### CI/CD
- Jenkins
- GitHub
- SSH Agent
- Automated Docker deployment
- Automated health verification

---

## 🔄 CI/CD Pipeline

The Jenkins pipeline performs the following stages:

### 1. Clone

Jenkins retrieves the latest source code from the GitHub `main` branch.

### 2. Build Docker Image

The application is packaged into a Docker image:

```bash
docker build -t cloudops-health-monitor .
```

### 3. Deploy to EC2-1

Jenkins connects to the first EC2 instance through SSH and:

```text
Pull latest code
      ↓
Remove existing container
      ↓
Build updated Docker image
      ↓
Start new container
```

### 4. Deploy to EC2-2

The same deployment process is automatically executed on the second EC2 instance.

### 5. Health Check

Jenkins verifies both deployments using:

```text
/health
```

The pipeline succeeds only when the deployed applications respond successfully.

---

## 🏗️ AWS Infrastructure

Terraform provisions the following resources:

```text
AWS VPC
│
├── Internet Gateway
│
├── Public Subnet 1
│   └── EC2 Instance 1
│
├── Public Subnet 2
│   └── EC2 Instance 2
│
├── Public Route Table
│
└── Security Group
    ├── SSH : 22
    └── Flask : 5000
```

The EC2 instances automatically install Docker and Git through Terraform `user_data`.

---

## 🐳 Docker

The application is packaged using a lightweight Python image.

### Build

```bash
docker build -t cloudops-health-monitor .
```

### Run

```bash
docker run -d \
  --name cloudops-monitor \
  --restart unless-stopped \
  -p 5000:5000 \
  cloudops-health-monitor
```

### Check container

```bash
docker ps
```

---

## ❤️ Health Monitoring

The application provides a dedicated health endpoint:

```text
GET /health
```

Example response:

```json
{
  "service": "cloudops-health-monitor",
  "status": "healthy"
}
```

This endpoint is used by Jenkins after deployment to verify that the application is running successfully.

---

## 📂 Project Structure

```text
cloudops-health-monitor/
│
├── app.py
├── Dockerfile
├── requirements.txt
├── .dockerignore
├── .gitignore
├── Jenkinsfile
├── main.tf
└── README.md
```

---

## 🚀 Local Setup

### Prerequisites

Make sure the following are installed:

- Python 3.12+
- Docker
- Git
- Terraform
- AWS CLI
- Jenkins
- AWS account

### Clone Repository

```bash
git clone https://github.com/shreya36-ship-it/cloudops-health-monitor.git
cd cloudops-health-monitor
```

### Run with Python

```bash
pip install -r requirements.txt
python app.py
```

Application:

```text
http://localhost:5000
```

Health endpoint:

```text
http://localhost:5000/health
```

---

## ☁️ Terraform Deployment

Initialize Terraform:

```bash
terraform init
```

Validate configuration:

```bash
terraform validate
```

Review infrastructure changes:

```bash
terraform plan
```

Create AWS infrastructure:

```bash
terraform apply
```

To remove the infrastructure after testing:

```bash
terraform destroy
```

> ⚠️ AWS resources may incur charges depending on account eligibility and resource usage. Destroy development infrastructure when it is no longer required.

---

## 🔐 Security Notes

For this learning project:

- EC2 access is configured through an SSH key pair.
- Jenkins uses an SSH Agent credential for automated deployment.
- AWS infrastructure is managed through Terraform.
- The GitHub repository is public so EC2 instances can clone the application without credentials.

For production environments, consider:

- Restricting SSH access to trusted IP addresses
- Using private subnets for application servers
- Using AWS Systems Manager instead of direct SSH
- Using IAM roles instead of long-lived credentials
- Using HTTPS/TLS
- Using an Application Load Balancer
- Storing secrets in AWS Secrets Manager or Parameter Store

---

## 📊 DevOps Workflow

```text
Developer
   │
   ▼
GitHub
   │
   ▼
Jenkins
   │
   ├── Clone
   │
   ├── Docker Build
   │
   ├── Deploy EC2-1
   │
   ├── Deploy EC2-2
   │
   └── Health Check
          │
          ▼
       SUCCESS
```

---

## 🎯 Learning Outcomes

Through this project, I practiced:

- Infrastructure as Code using Terraform
- AWS networking fundamentals
- EC2 provisioning and deployment
- Docker containerization
- Jenkins CI/CD pipeline development
- SSH-based automated deployment
- Git/GitHub workflows
- Multi-instance application deployment
- Automated post-deployment validation
- Basic cloud security concepts

---

## 🔮 Future Improvements

Potential improvements include:

- [ ] Add an AWS Application Load Balancer
- [ ] Add Auto Scaling
- [ ] Add HTTPS with TLS
- [ ] Add CloudWatch monitoring
- [ ] Add centralized logging
- [ ] Add automated rollback
- [ ] Add Docker BuildKit/buildx
- [ ] Add Jenkins webhook-based automatic builds
- [ ] Deploy using AWS Systems Manager
- [ ] Add production-grade secret management
- [ ] Add automated unit and integration tests

---

## 👩‍💻 Author

**Shreya Princy**

3rd Year Computer Science Engineering Student  
Interested in **Cloud Computing, DevOps, AI/ML and Data Analytics**

### Tech Focus

```text
Python • SQL • AWS • Azure • Docker • Jenkins
Terraform • Kubernetes • Git • GitHub • Flask
```

---

⭐ If you found this project useful, consider giving the repository a star!
