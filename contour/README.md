#### setup zen route with contour Gateway API on openshift

1. use option 3 here https://projectcontour.io/getting-started/#option-3-contour-gateway-provisioner as reference  
2. `oc apply -f contour-gateway-provisioner.yaml`, install crds and gateway controller to `projectcontour` namespace, note potential conflicts on openshift 4.19 as openshift manages Gateway API crds  
3. `oc apply -f gatewayclass.yaml`  
4. `oc apply -f ocp4732.yaml`  
5. `oc apply -f gateway.yaml`  
  this will create contour deployment with two pods runs under restricted-v2 scc amd envoy daemonsets with 3 pods runs under anyuid scc with userid 65534  
  `oc edit deploy contour-zen-gateway -n projectcontour` and remove 65534 from securityContext [TODO, use `ContourDeployment` for customizarion]  
  `oc adm policy add-scc-to-user anyuid -z envoy-zen-gateway -n projectcontour`, this will bring up envoy daemonsets
6. contout envoy does not support `ssl_ecdh_curve secp384r1`, for now downgrade nginx 
  this is not supported by contour envoy with non-fips builds (latest 1.33), included with fips build however, needs to build yourself.  
7. `oc apply -f httproutes.yaml -n zen`  
8. `oc apply -f ca-certs.yaml -n zen`  
9. `oc apply -f backendtlspolicies.yaml -n zen`, this will use `BackendTLSPolicy.networking.k8s.io/v1alpha3` for routing to upstream services  
10. rest same as 8-11 in istio

zen console should be available at https://zen-cpd.apps.ocp4732.cp.fyre.ibm.com:30443
