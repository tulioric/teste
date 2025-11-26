#!/bin/bash

OUTPUT="inventario_openshift.csv"
echo "namespace,nome,tipo,referencia_rabbitmq,referencia_dynatrace" > $OUTPUT

# Lista namespaces evitando os de sistema
for NS in $(oc get ns --no-headers | awk '{print $1}' | grep -vE 'openshift|kube|redhat'); do
    
    ### Deployments
    for NAME in $(oc get deployment -n $NS --no-headers 2>/dev/null | awk '{print $1}'); do
        DESC=$(oc get deployment $NAME -n $NS -o yaml)
        RABBIT=$(echo "$DESC" | grep -iE 'rabbitmq|amqp' >/dev/null && echo "sim" || echo "não")
        DYNA=$(echo "$DESC" | grep -i "dynatrace" >/dev/null && echo "sim" || echo "não")
        echo "$NS,$NAME,Deployment,$RABBIT,$DYNA" >> $OUTPUT
    done

    ### DeploymentConfigs
    for NAME in $(oc get dc -n $NS --no-headers 2>/dev/null | awk '{print $1}'); do
        DESC=$(oc get dc $NAME -n $NS -o yaml)
        RABBIT=$(echo "$DESC" | grep -iE 'rabbitmq|amqp' >/dev/null && echo "sim" || echo "não")
        DYNA=$(echo "$DESC" | grep -i "dynatrace" >/dev/null && echo "sim" || echo "não")
        echo "$NS,$NAME,DeploymentConfig,$RABBIT,$DYNA" >> $OUTPUT
    done

    ### StatefulSets
    for NAME in $(oc get statefulset -n $NS --no-headers 2>/dev/null | awk '{print $1}'); do
        DESC=$(oc get statefulset $NAME -n $NS -o yaml)
        RABBIT=$(echo "$DESC" | grep -iE 'rabbitmq|amqp' >/dev/null && echo "sim" || echo "não")
        DYNA=$(echo "$DESC" | grep -i "dynatrace" >/dev/null && echo "sim" || echo "não")
        echo "$NS,$NAME,StatefulSet,$RABBIT,$DYNA" >> $OUTPUT
    done

done

echo "✔ CSV gerado: $OUTPUT"
