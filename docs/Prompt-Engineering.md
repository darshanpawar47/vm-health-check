# Prompt Engineering for DevOps

## Objective

This document explains how to use prompt engineering in DevOps workflows. It is written for engineers who want practical, beginner-friendly guidance that applies to infrastructure, automation, and cloud operations.

---

## Why Prompt Engineering Matters in DevOps

Prompt engineering helps teams get more useful output from AI tools. In DevOps, it is especially valuable for:

- generating repeatable shell commands
- drafting infrastructure-as-code
- troubleshooting errors quickly
- writing CI/CD pipelines
- documenting operational procedures

These prompts are most effective when they include context, examples, and a clear goal.

---

## Real DevOps Use Cases

### 1. Incident response

Use AI to format runbooks, search for common error patterns, and propose remediation steps.

Example goal:
- "Explain how to recover a Kubernetes pod that is stuck in `CrashLoopBackOff`."

### 2. Infrastructure automation

Ask AI to generate reusable Terraform code or AWS CLI commands for provisioning resources.

Example goal:
- "Create a Terraform module for an S3 bucket with versioning and lifecycle rules."

### 3. Observability and monitoring

Generate CloudWatch alarm definitions, Prometheus rules, or log query examples.

Example goal:
- "Write a Prometheus alert that fires when CPU utilization is above 80% for 5 minutes."

### 4. Security and compliance

Request guidance on IAM policies, network ACLs, or hardening scripts.

Example goal:
- "Show a secure Dockerfile pattern for a Python web application."

### 5. Cost optimization

Ask for recommendations on rightsizing instances, removing unused resources, or using spot instances.

Example goal:
- "List steps to reduce AWS EC2 spend for a staging environment."

---

## AWS Examples

### Prompt style

Provide the environment, the goal, and the constraints.

Example prompt:

> Create an AWS CLI command to enable versioning on the `my-app-logs` S3 bucket.

Result:

```bash
aws s3api put-bucket-versioning \
  --bucket my-app-logs \
  --versioning-configuration Status=Enabled
```

### Use case: EC2 instance metadata

Prompt:

> Write a Bash command that prints the AWS region for the current EC2 instance.

Result:

```bash
curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region'
```

### Use case: CloudWatch alarm

Prompt:

> Generate a Terraform resource for a CloudWatch alarm that triggers when CPU usage is over 90% for 3 minutes.

Result snippet:

```hcl
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 180
  statistic           = "Average"
  threshold           = 90
  dimensions = {
    InstanceId = var.instance_id
  }
}
```

---

## Kubernetes Examples

### Prompt style

Ask for manifest templates or troubleshooting commands.

Example prompt:

> Provide a Kubernetes Deployment manifest for a simple web app with 2 replicas.

Result:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web-app
        image: nginx:stable
        ports:
        - containerPort: 80
```

### Use case: kubectl troubleshooting

Prompt:

> Show the command to find pods in the `production` namespace that are not ready.

Result:

```bash
kubectl get pods -n production --field-selector=status.phase!=Running
```

### Use case: scaling deployments

Prompt:

> Write a command to scale `frontend` deployment to 4 replicas.

Result:

```bash
kubectl scale deployment frontend --replicas=4
```

---

## Docker Examples

### Prompt style

Ask for a Dockerfile, compose file, or a command to inspect an image.

Example prompt:

> Create a Dockerfile for a Node.js app that uses a lightweight base image.

Result:

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . ./
EXPOSE 3000
CMD ["node", "server.js"]
```

### Use case: docker-compose

Prompt:

> Generate a simple `docker-compose.yml` for a web service and Redis.

Result:

```yaml
version: '3.9'
services:
  web:
    image: my-web-app:latest
    ports:
      - "8080:80"
    depends_on:
      - redis
  redis:
    image: redis:alpine
```

### Use case: container debugging

Prompt:

> Write a Docker command to run a temporary container and inspect the environment.

Result:

```bash
docker run --rm -it my-web-app:latest sh
```

---

## Terraform Examples

### Prompt style

Request resource blocks and variable definitions.

Example prompt:

> Create a Terraform resource for an AWS VPC with a public subnet.

Result:

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true
}
```

### Use case: variables and outputs

Prompt:

> Show a Terraform variable definition for an EC2 instance type and an output for the instance ID.

Result:

```hcl
variable "instance_type" {
  type    = string
  default = "t3.micro"
}

output "instance_id" {
  value = aws_instance.app.id
}
```

### Use case: plan and apply

Prompt:

> What is the Terraform CLI command to preview changes before applying?

Result:

```bash
terraform plan
```

---

## Bash Scripting Examples

### Prompt style

Ask for a function, a command sequence, or a script that follows best practices.

Example prompt:

> Write a Bash function that returns the available disk space percentage for `/`.

Result:

```bash
get_root_disk_usage() {
  df -P / | awk 'NR==2 {gsub("%", "", $5); print $5}'
}
```

### Use case: safe scripting

Prompt:

> Show a Bash script header that exits on error and treats unset variables as failures.

Result:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Script logic here
```

### Use case: automation helpers

Prompt:

> Create a Bash function that checks if a command exists and prints an error if it does not.

Result:

```bash
require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Error: $1 is required" >&2
    exit 1
  }
}
```

---

## CI/CD Examples

### Prompt style

Ask for pipeline stages, YAML definitions, or deployment workflows.

Example prompt:

> Generate a GitHub Actions workflow that runs tests on push to `main`.

Result:

```yaml
name: CI
on:
  push:
    branches: [ main ]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      - name: Install dependencies
        run: npm install
      - name: Run tests
        run: npm test
```

### Use case: build and deploy

Prompt:

> Write a GitLab CI job that builds a Docker image and pushes it to registry.

Result:

```yaml
build:
  stage: build
  image: docker:24
  services:
    - docker:dind
  script:
    - docker build -t registry.example.com/my-app:$CI_COMMIT_SHORT_SHA .
    - docker push registry.example.com/my-app:$CI_COMMIT_SHORT_SHA
```

### Use case: gating production deploys

Prompt:

> Create a pipeline stage that deploys only when a tag is created.

Result:

```yaml
deploy:
  stage: deploy
  only:
    - tags
  script:
    - ./deploy.sh
```

---

## Prompting Techniques for DevOps

### Zero-Shot Prompting

Definition: ask AI to perform a task without giving examples.

Example:

> Write a Bash script that checks CPU, memory, and disk utilization.

Use it when the task is simple and you want a quick result.

### Few-Shot Prompting

Definition: provide one or more examples before asking for new output.

Example:

> Here is a Bash function that checks CPU utilization.
> Now write similar functions for memory and disk utilization.

Use it when you want consistent style or repeated patterns.

### Multi-Shot Prompting

Definition: provide several examples so the model understands the pattern.

Example:

> Example: CPU function
> Example: Memory function
> Example: Disk function
> Now generate a logging function using the same style.

It is useful when the output must follow a specific structure.

### Chain of Thought Prompting

Definition: ask AI to explain reasoning step by step.

Example:

> My Bash script returns "Permission denied." Explain how to troubleshoot it.

This helps when you need to understand the problem, not just get a fix.

---

## Best Practices

- Be specific about the platform and tooling.
- Provide context such as cloud provider, shell type, or deployment target.
- Use comments to make generated scripts easier to review.
- Ask AI to explain output when you need confidence.
- Validate generated code before applying it in production.
- Keep prompts focused on one task at a time.

---

## Summary

For DevOps, prompt engineering is most effective when you:

- describe the environment clearly
- ask for examples or templates
- request code in a specific syntax
- verify output with manual review

Use this document as a reference when writing prompts for AWS, Kubernetes, Docker, Terraform, Bash, and CI/CD tasks.