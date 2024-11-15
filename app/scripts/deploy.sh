#!/bin/bash

# Configuration
ECR_REGISTRY="651706773745.dkr.ecr.us-east-2.amazonaws.com"
ECR_REPOSITORY="fastapi-app"
EC2_HOST="3.147.43.129"
EC2_USER="ec2-user"
AWS_REGION="us-east-2"

# Ensure commit message was provided
if [ -z "$1" ]; then
    echo "Please provide a commit message"
    echo "Usage: ./deploy.sh \"your commit message\""
    exit 1
fi

# Git operations
echo "📦 Committing changes..."
git add .
git commit -m "$1"
git push origin main

# Build Docker image
echo "🔨 Building Docker image..."
docker build -t $ECR_REPOSITORY:latest .

# Login to ECR
echo "🔑 Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

# Tag and push image
echo "📤 Pushing image to ECR..."
docker tag $ECR_REPOSITORY:latest $ECR_REGISTRY/$ECR_REPOSITORY:latest
docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest

# Deploy to EC2
echo "🚀 Deploying to EC2..."
ssh -i ~/.ssh/secureadi.pem $EC2_USER@$EC2_HOST "
    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY
    docker pull $ECR_REGISTRY/$ECR_REPOSITORY:latest
    docker stop $ECR_REPOSITORY || true
    docker rm $ECR_REPOSITORY || true
    docker run -d --name $ECR_REPOSITORY -p 80:80 $ECR_REGISTRY/$ECR_REPOSITORY:latest
"

echo "✅ Deployment complete!"