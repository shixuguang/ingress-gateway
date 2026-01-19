
#### Setup zen route with gateway:

step tested with openshift 4.18, 4.19  

1. install openshift istio https://docs.redhat.com/en/documentation/red_hat_openshift_service_mesh/3.1/html/installing/ossm-installing-service-mesh  
   we use istio for traffic management only, doesn't matter which istio mode to use, by default, istio installed as side car injection mode  
2. add the following lables to zen namespace:  
  istio-discovery: enabled  
  ~~ istio-injection: enabled ~~ # this controls side car injection for every pod  
3. setup haproxy routing to backend on port 30443 in infra node
4. use zen-cpd.apps.ocp4732.cp.fyre.ibm.com:30443 to route to zen
5. run the following commands for zen namespace:  
  - create gateway default certificate, we're using the same openshift ingress uses:  
    ```
    oc get secret router-certs-default -n openshift-ingress -o json | jq 'del(.metadata.namespace,.metadata.ownerReferences) | .metadata.name = "ocp4732" | .metadata.namespace = "zen"' | oc apply -f - 
    ```  
  - create backend service ca certificate for nginx service and iam services  
    ```
    oc create secret generic ocp4732-iam-ca --from-literal=cacert="$(oc get secret cs-ca-certificate-secret -o jsonpath='{.data.tls\.crt}' | base64 -d)"  
    
    oc create secret generic ocp4732-nginx-ca --from-literal=cacert="$(oc get secret ibm-nginx-internal-tls-ca -o jsonpath='{.data.cert\.crt}' | base64 -d)"
    ```
6. option A: 
    - let istio gateway controller to create gateway service (with extra step in 7)
    - use as much standard gateway apis except backendtlspolices, use istio preporitery api destinationRules instead  
    
    `oc apply -f zen-gateway-api.yaml -n zen`  

      the following resources deployed:
      - Gateway.gateway.networking.k8s.io/v1 for zen, gateway instance and service created
      - EnvoyFilter.networking.istio.io/v1alpha3 to enable `ssl_ecdh_curve secp384r1` which is a requirement for zen, by default this is not supported by openshift istio/envoy
      - HTTPRoutes.gateway.networking.k8s.io/v1 for zen and iam
      - DestinationRule.networking.istio.io/v1 for zen and iam (see comments)
      <!-- 
        * as of ocp4.19 support of Gateway API is 1.2.1, in which BackendTLSPolicy is experimental feature v1alpha2, openshift istio does not support experimental feature 
        * BackendTLSPolicy.networking.k8s.io is officially supported by kubernetes as of Gateway API 1.4.0
        * as of ocp4.19 openshift manages Gateway API CRDs on openshift clusters
      -->
    option B:  
      - create gateway service manually instead of gateway controller, use istio priporitery apis  

    `oc apply -f zen-gateway.yaml -n zen`  
      this will deploy all `istio.io` properitery resources including manually self-managed gateway instance and service, step 7 can be skipped in this case  
7. `oc edit svc zen-gateway-istio` and modify NodePort for https to 30443
8. make sure product-configmap URL_PREFIX: zen-cpd.apps.ocp4732.cp.fyre.ibm.com:30443  
9. add the following to commonservice cr under cpd operator namespace:
    ```
      services:
      - name: ibm-im-operator
        spec:
          authentication:
            config:
              ingress:
                hostname: zen-cpd.apps.ocp4732.cp.fyre.ibm.com:30443
    ```  
    and make sure the following have updated:  
    ```
      oc edit cm - ibmcloud-cluster-info
      data:
        cluster_address: zen-cpd.apps.ocp4732.cp.fyre.ibm.com:30443
        cluster_address_auth: zen-cpd.apps.ocp4732.cp.fyre.ibm.com:30443
        cluster_endpoint: https://zen-cpd.apps.ocp4732.cp.fyre.ibm.com:30443

      oc edit cm platform-auth-idp
        data:
          MASTER_HOST: zen-cpd.apps.ocp4732.cp.fyre.ibm.com:30443  
    ```
9. `oc edit client zenclient-zen`:  
  ```
    spec:
      oidcLibertyClient:
        post_logout_redirect_uris:
        - https://zen-cpd.apps.ocp4732.cp.fyre.ibm.com:30443/auth/doLogout
        redirect_uris:
        - https://zen-cpd.apps.ocp4732.cp.fyre.ibm.com:30443/auth/login/oidc/callback
        trusted_uri_prefixes:
        - https://zen-cpd.apps.ocp4732.cp.fyre.ibm.com:30443
  ```
  
zen console should be available at https://zen-cpd.apps.ocp4732.cp.fyre.ibm.com:30443