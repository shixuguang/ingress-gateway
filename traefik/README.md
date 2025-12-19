#### Traefik

1. `helm install traefik traefik/traefik -n traefik -f values.yaml [--wait]`  
  use `--wait` with LoadBalancer available only, we're using NortPort here
  for testing, patch nortPort to desired port:  
    ```
      oc patch svc traefik --type='json' -p='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value": 31836}]' -n traefik
      oc patch svc traefik --type='json' -p='[{"op": "replace", "path": "/spec/ports/1/nodePort", "value": 30443}]' -n traefik
    ```  
2. `oc apply -f ca-certs-cm.yaml -n zen`  
3. `oc apply -f httproutes.yaml -n zen`  
4. `oc apply -f backendtlspolicies.yaml -n zen`
...

zen console is available at: https://zen-cpd.apps.ocp4732.cp.fyre.ibm.com:30443  
traefik dashboard is available at: https://traefik.apps.ocp4732.cp.fyre.ibm.com:31836/dashboard/