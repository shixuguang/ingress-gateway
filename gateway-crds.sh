oc apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/refs/heads/main/config/crd/standard/gateway.networking.k8s.io_backendtlspolicies.yaml
oc apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/refs/heads/main/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml
oc apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/refs/heads/main/config/crd/standard/gateway.networking.k8s.io_gateways.yaml
oc apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/refs/heads/main/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml

