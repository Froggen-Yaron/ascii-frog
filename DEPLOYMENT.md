# Photo Frog Generator - Deployment Guide

## Overview

This document provides comprehensive deployment instructions for the Photo Frog Generator application using Docker and Kubernetes with Helm.

## Prerequisites

- Docker 20.10+
- Kubernetes 1.20+
- Helm 3.8+
- kubectl configured for your cluster

## Quick Start with Docker

### 1. Build the Docker Image

```bash
# Build the image
docker build -t photo-frog:1.0.0 .

# Verify the image was created
docker images | grep photo-frog
```

### 2. Run with Docker Compose

```bash
# Start the application
docker-compose up -d

# Check the status
docker-compose ps

# View logs
docker-compose logs -f photo-frog

# Access the application
curl http://localhost:8080/api/health
```

### 3. Development Mode

```bash
# Start in development mode
docker-compose --profile dev up -d

# Access on port 8081
curl http://localhost:8081/api/health
```

## Kubernetes Deployment with Helm

### 1. Install the Helm Chart

```bash
# Add the chart repository (if using a repository)
helm repo add photo-frog https://your-repo.com/charts

# Install the chart
helm install photo-frog ./helm/photo-frog

# Or install with custom values
helm install photo-frog ./helm/photo-frog -f custom-values.yaml
```

### 2. Verify the Deployment

```bash
# Check all resources
kubectl get all -l app.kubernetes.io/name=photo-frog

# Check pods
kubectl get pods -l app.kubernetes.io/name=photo-frog

# Check services
kubectl get svc -l app.kubernetes.io/name=photo-frog

# Check ingress (if enabled)
kubectl get ingress -l app.kubernetes.io/name=photo-frog
```

### 3. Access the Application

```bash
# Port forward to access the service
kubectl port-forward svc/photo-frog 8080:80

# Or use the service URL if LoadBalancer
kubectl get svc photo-frog -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Test the health endpoint
curl http://localhost:8080/api/health
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| SPRING_PROFILES_ACTIVE | production | Spring profile to use |
| JAVA_OPTS | -Xmx512m -Xms256m | JVM options |

### Resource Limits

Default resource configuration:
- CPU Request: 250m
- CPU Limit: 500m
- Memory Request: 256Mi
- Memory Limit: 512Mi

### Autoscaling

The application supports Horizontal Pod Autoscaling:
- Min Replicas: 2
- Max Replicas: 10
- CPU Target: 80%
- Memory Target: 80%

## Production Deployment

### 1. Create Production Values

```yaml
# production-values.yaml
replicaCount: 3
image:
  repository: your-registry/photo-frog
  tag: "1.0.0"
  pullPolicy: Always

resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 20

ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: photo-frog.yourdomain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: photo-frog-tls
      hosts:
        - photo-frog.yourdomain.com
```

### 2. Deploy to Production

```bash
# Create namespace
kubectl create namespace photo-frog-prod

# Install with production values
helm install photo-frog-prod ./helm/photo-frog \
  --namespace photo-frog-prod \
  -f production-values.yaml

# Verify deployment
helm status photo-frog-prod -n photo-frog-prod
```

## Monitoring and Health Checks

### Health Endpoints

- **Liveness Probe**: `/api/health`
- **Readiness Probe**: `/api/health`
- **Actuator Endpoints**: `/actuator/health`, `/actuator/info`, `/actuator/metrics`

### Monitoring Setup

```bash
# Enable Prometheus metrics
kubectl patch deployment photo-frog -p '{"spec":{"template":{"metadata":{"annotations":{"prometheus.io/scrape":"true","prometheus.io/port":"8080"}}}}}}'
```

## Troubleshooting

### Common Issues

1. **Pod not starting**
   ```bash
   kubectl describe pod <pod-name>
   kubectl logs <pod-name>
   ```

2. **Health check failures**
   ```bash
   kubectl exec -it <pod-name> -- curl localhost:8080/api/health
   ```

3. **Resource constraints**
   ```bash
   kubectl top pods -l app.kubernetes.io/name=photo-frog
   ```

### Logs

```bash
# View application logs
kubectl logs -f deployment/photo-frog

# View logs from specific pod
kubectl logs -f <pod-name>

# View logs from previous container (if restarted)
kubectl logs -f <pod-name> --previous
```

## Security Considerations

### 1. Network Policies

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: photo-frog-network-policy
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: photo-frog
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to: []
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
```

### 2. Security Context

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  runAsGroup: 1000
  fsGroup: 1000
  capabilities:
    drop:
    - ALL
```

## Backup and Recovery

### 1. Backup Configuration

```bash
# Export current configuration
helm get values photo-frog > backup-values.yaml

# Export secrets (if any)
kubectl get secret photo-frog-secret -o yaml > backup-secret.yaml
```

### 2. Recovery

```bash
# Restore from backup
helm install photo-frog-restored ./helm/photo-frog -f backup-values.yaml

# Apply secrets
kubectl apply -f backup-secret.yaml
```

## Updates and Rollbacks

### 1. Update Application

```bash
# Update to new version
helm upgrade photo-frog ./helm/photo-frog --set image.tag=1.1.0

# Check status
helm status photo-frog
```

### 2. Rollback

```bash
# List revisions
helm history photo-frog

# Rollback to previous version
helm rollback photo-frog 1

# Verify rollback
helm status photo-frog
```

## Support

For issues and support:
- GitHub Issues: https://github.com/your-org/photo-frog/issues
- Documentation: https://github.com/your-org/photo-frog/docs
- Email: team@froggen.com
