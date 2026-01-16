# CRDs 1.2.1 managed by openshift 4.19+ and not mutable, need to remove before upgrade
oc apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/refs/heads/main/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml
oc apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/refs/heads/main/config/crd/standard/gateway.networking.k8s.io_gateways.yaml
oc apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/refs/heads/main/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml
# v1.4 not admitted by openshift 4.19,4.20
oc apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/refs/heads/main/config/crd/standard/gateway.networking.k8s.io_backendtlspolicies.yaml

# traefik gatewayclass/gatewaycontroller not accepted openshift 4.19
```
NAME           CONTROLLER                      ACCEPTED   AGE
istio          istio.io/gateway-controller     True       2d1h
istio-remote   istio.io/unmanaged-gateway      True       2d1h
traefik        traefik.io/gateway-controller   Unknown    25h 
```
traefik controller error due to backendtlspolicy:
E0116 23:04:15.880025       1 reflector.go:205] "Failed to watch" err="failed to list *v1.BackendTLSPolicy: the server could not find the requested resource (get backendtlspolicies.gateway.networking.k8s.io)" logger="UnhandledError" reflector="k8s.io/client-go@v0.34.1/tools/cache/reflector.go:290" type="*v1.BackendTLSPolicy"