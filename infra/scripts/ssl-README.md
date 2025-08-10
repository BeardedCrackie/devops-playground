## 1. Create your CA

``` bash
# Generate CA key
openssl genrsa -out ca.key 4096

# Create self-signed CA cert with minimal subject (just CN)
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 \
  -out ca.crt \
  -subj "/CN=k8s.local"
  ```

## 2. Create wildcard CSR and cert

``` bash
# Generate wildcard private key
openssl genrsa -out wildcard.k8s.local.key 2048

# Create CSR config with minimal info
cat > wildcard-csr.conf <<EOF
[ req ]
default_bits       = 2048
prompt             = no
default_md         = sha256
req_extensions     = req_ext
distinguished_name = dn

[ dn ]
CN = *.k8s.local

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = *.k8s.local
DNS.2 = k8s.local
EOF

# Generate CSR
openssl req -new -key wildcard.k8s.local.key -out wildcard.k8s.local.csr -config wildcard-csr.conf

# Sign with CA
openssl x509 -req -in wildcard.k8s.local.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out wildcard.k8s.local.crt -days 825 -sha256 -extfile wildcard-csr.conf -extensions req_ext
```

## 3. Create Kubernetes TLS secret
``` bash
kubectl create secret tls wildcard-k8s-local-tls \
  --cert=wildcard.k8s.local.crt \
  --key=wildcard.k8s.local.key \
  -n ingress-nginx
```
