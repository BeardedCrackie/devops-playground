# Tasklist App Deploy Overview

```
kind load docker-image tasklist-backend:latest
kind load docker-image tasklist-frontend:latest
```

```
helm install tasklist-app . --create-namespace
```

```
helm upgrade tasklist-app .
```

```
helm uninstall tasklist-app
```

```
kubectl port-forward svc/tasklist-frontend 8080:80
```