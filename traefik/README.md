#### Traefik

1. `helm install traefik traefik/traefik -n traefik -f values.yaml [--wait]`  
  use `--wait` with LoadBalancer available only, we're using NortPort here
  for testing, patch nortPort to desired port:  
    ```
      oc patch svc traefik --type='json' -p='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value": 31836}]' -n traefik
      oc patch svc traefik --type='json' -p='[{"op": "replace", "path": "/spec/ports/1/nodePort", "value": 30443}]' -n traefik
    ```  
2. create an entry for node port on infra node haproxy  
3. `oc apply -f zen-gateway.yaml`  
4. create cm `ocp4732-nginx-ca` and `ocp4732-iam-ca`
    ```
        oc extract secret/ibm-nginx-internal-tls-ca --keys=cert.crt
        oc create cm ocp4732-nginx-ca --from-file=ca.crt=./cert.crt

        oc extract secret/cs-ca-certificate-secret --keys=ca.crt
        oc create cm ocp4732-iam-ca --from-file=ca.crt=./ca.crt
    ```

5. `oc apply -f httproutes.yaml -n zen`  
6. `oc apply -f backendtlspolicies.yaml -n zen`
7. iam installed with `spec.authentication.config.ingress.hostname: zen-cpd.apps.ocp4732.cp.fyre.ibm.com:30443` without route creation
8. modify zen client object with redirect url: zen-cpd.apps.ocp4732.cp.fyre.ibm.com:30443

zen console is available at: https://zen-cpd.apps.ocp4732.cp.fyre.ibm.com:30443  
traefik dashboard is available at: https://traefik.apps.ocp4732.cp.fyre.ibm.com:31836/dashboard/